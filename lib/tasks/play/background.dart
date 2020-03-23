import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayer/audioplayer.dart';
import './actions.dart';
import '../../api/api.dart';
import '../../libs/libs.dart';

void backgroundEntry() {
  AudioServiceBackground.run(() => _BackgroundMusicTask());
}

class _BackgroundMusicTask extends BackgroundAudioTask {
  SongModel song;
  SongSourceModel source;
  String file;
  Completer completer;
  AudioPlayer player = AudioPlayer();
  String root;
  int position = 0;
  int duration = 0;
  bool loading = false;
  bool downloading = false;
  bool lock = false;
  List<StreamSubscription> listeners = List<StreamSubscription>();

  BasicPlaybackState get _basicState => AudioServiceBackground.state.basicState;

  Future<SongModel> load(int i) async {
    if (loading) return null;

    Fs fs = Fs('playmode');
    int mode = int.parse(await fs.read('0'));
    bool random = false;

    if (mode == 1) random = true;

    loading = true;
    SongModel model = await (i == 1
        ? PlayApi().next(random: random, single: mode == 2)
        : PlayApi().previous(random: random, single: mode == 2));
    loading = false;
    return model;
  }

  setPlayState([BasicPlaybackState state = BasicPlaybackState.playing]) async {
    await AudioServiceBackground.setState(
      controls: [
        state != BasicPlaybackState.playing ? PLAY_CONTROL : PAUSE_CONTROL
      ],
      basicState: state,
      position: position,
    );
  }

  setMediaItem() async {
    await AudioServiceBackground.setMediaItem(
      MediaItem(
        id: '${song.id}@${song.type}',
        album: song.singers,
        title: song.name,
        duration: duration,
        artUri: source != null ? '$root/${source.img}' : '',
      ),
    );
  }

  @override
  Future<void> onStart() async {
    root = await Fs.root();
    listening();
    play(await PlayApi().getPlaying());
    completer = Completer();
    return completer.future;
  }

  listening() {
    listeners = [
      player.onAudioPositionChanged.listen((data) async {
        position = data.inMilliseconds;
      }),

      player.onPlayerStateChanged.listen((state) {
        if (state == AudioPlayerState.PAUSED) {
          setPlayState(BasicPlaybackState.paused);
        } else if (state == AudioPlayerState.PLAYING) {
          duration = player.duration.inMilliseconds;
          setMediaItem();
          setPlayState();
        } else if (state == AudioPlayerState.COMPLETED) {
          onSkipToNext();
        }
      }),
    ];
  }

  Future<void> play(SongModel model) async {
    lock = true;
    //1.5秒内只允许一次上下切换
    Future.delayed(Duration(milliseconds: 1500), () => lock = false);

    player.stop();
    position = 0;
    duration = 0;
    song = model;
    file = '';
    
    await setPlayState(BasicPlaybackState.connecting);
    await setMediaItem();

    //这边要处理下，如果疯狂点击去load，导致延迟回来source错乱的问题。
    SongApi api = SongApiFactory.create(song.id, song.type);
    SongSourceModel _source = await api.source();

    if (_source == null) {
      lock = false;
      onSkipToNext();
      return;
    } else if (_source.id != song.id && _source.type != song.type) {
      return;
    }

    source = _source;
    await setPlayState(BasicPlaybackState.buffering);
    file = '$root/${source.file}';
    Future.delayed(Duration(milliseconds: 200), () => player.play(file, isLocal: true));
  }

  @override
  void onPlay() async {
    if (_basicState == BasicPlaybackState.connecting) {
      return ;
    }

    SongModel model = await PlayApi().getPlaying();

    if (model.id == song.id && model.type == song.type) {
      player.play(file);
    } else {
      play(model);
    }
  }

  @override
  void onPause() async {
    if (_basicState == BasicPlaybackState.playing || _basicState == BasicPlaybackState.paused) {
      player.pause();
    }
  }

  @override
  void onSkipToNext() async {
    if (lock) return;

    await setPlayState(BasicPlaybackState.skippingToNext);
    
    SongModel song = await load(1);

    if (song != null) play(song);
  }

  @override
  void onSkipToPrevious() async {
    if (lock) return;

    setPlayState(BasicPlaybackState.skippingToPrevious);
   
    SongModel song = await load(-1);

    if (song != null) play(song);
  }

  @override
  void onSeekTo(int pos) {
    player.play(file);
    player.seek((pos ~/ 1000).toDouble());
    position = pos;
    setPlayState();
  }

  @override
  void onStop() async {
    if (BasicPlaybackState.stopped == _basicState) return;

    await player.stop();
    listeners.forEach((StreamSubscription stream) {
      stream.cancel();
    });
    listeners = null;
    //player = null;
    setPlayState(BasicPlaybackState.stopped);
    completer.complete();
  }
}
