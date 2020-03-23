// if (flutterWebviewPlugin != null) {
//       flutterWebviewPlugin.close();
//       flutterWebviewPlugin.dispose();
//     }

//     flutterWebviewPlugin = new FlutterWebviewPlugin();
//     flutterWebviewPlugin.launch('https://music.163.com/m/song?id=1416387774',
//     //flutterWebviewPlugin.launch('https://www.kugou.com/song/#album_id=34046129',
//       // headers: {
//       //   'user-agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1'
//       // },
//       hidden: true,
//       withJavascript: true,
//       rect: new Rect.fromLTWH(
//         0.0,
//         0.0,
//         MediaQuery.of(context).size.width,
//         600,
//       ),
//       javascriptChannels: [
//         JavascriptChannel(name: '_abc', onMessageReceived: (JavascriptMessage mesg) {
//           print('come from webview : ${mesg.message}');
//         })
//       ].toSet()
//     );

//     flutterWebviewPlugin.onStateChanged.listen((viewState) async {
//       print(viewState.type);

//       if (viewState.type == WebViewState.startLoad) {
//         // 网易云，测试通过
//         await flutterWebviewPlugin.evalJavascript('''
//           (function(){
//             var _ = window.XMLHttpRequest.prototype.open;
//             window.XMLHttpRequest.prototype.open = function() {
//               this.onloadend = function(event) {
//                 if (event.currentTarget.responseURL.indexOf('player/url/v1') > -1) {
//                   var element = document.createElement('div');
//                   var obj = JSON.parse(event.currentTarget.responseText);
//                   element.innerHTML = obj.data[0].url;
//                   element.style.cssText = 'height: 100px; background: red; width: 100px;position: absolute; z-index: 100;';
//                   document.body.insertBefore(element, document.body.children[0]);
//                   window._abc.postMessage(element.innerHTML);
//                 }

//               } ;
//               _.apply(this, arguments);
//             };
//           })()
//         ''');
//       }

//       if (viewState.type == WebViewState.finishLoad) {
//         // 酷狗， 测试通过 列表是一个jsonp
//         // await flutterWebviewPlugin.evalJavascript('''
//         //   var element = document.querySelector('audio');
//         //   _abc.postMessage(element.src);
//         // ''');
//       }
//     });

//     // QQ音乐，测试通过
//     // Helper.fetch.get('https://i.y.qq.com/v8/playsong.html?ADTAG=newyqq.song&songmid=0032hBG503yOCR', options: Options(
//     //   headers: {
//     //     'user-agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1'
//     //   },
//     // )).then((Response data) {
//     //   print(RegExp(r'(?<=<audio id="h5audio_media"[\s\S]+?src=")[^"]+').stringMatch(data.data));
//     // });

import 'dart:convert';
import '../../configs/configs.dart';
import '../../libs/libs.dart';
import '../../models/models.dart';
import './song.dart';

class QQSongApi extends SongApi {
  final int type = Types.QQ;
  static const String _INFO_URL = 'https://u.y.qq.com/cgi-bin/musicu.fcg';
  static const String _PLAY_URL =
      'https://i.y.qq.com/v8/playsong.html?ADTAG=newyqq.song&songmid=';
  static final Options _options = Options(
    headers: {
      'user-agent': MOBILE_UA,
    },
  );
  static final RegExp _songReg =
      RegExp(r'(?<=window.songlist = )([\s\S]+?)(?=;[\r\n])');

  QQSongApi(String id) : super(id);

  Future<SongSourceModel> getOnlineInfo() async {
    List res = await Future.wait([getOnlineLrc(), getPlayInfo()]);
    return SongSourceModel(
      lrc: res[0],
      file: res[1]['m4aUrl'],
      img: 'https:${res[1]["pic"]}',
      duration: res[1]['interval'] * 1000,
    );
  }

  Future<String> getOnlineLrc() async {
    try {
      return '';
      return Helper.fetch
          .post(
        _INFO_URL,
        data: jsonEncode({
          "detail": {
            "module": "music.pf_song_detail_svr",
            "method": "get_song_detail",
            "param": {
              "song_mid": id,
            },
          }
        }),
        options: _options,
      )
          .then((Response data) {
        Map res = jsonDecode(data.data);
        return List.from(res['detail']['data']['info'])
            .last['content'][0]['value']
            .toString();
      }).catchError((e) {
        return '';
      });
    } catch (e) {
      return '';
    }
  }

  Future<Map> getPlayInfo() async {
    try {
      return Helper.fetch
          .get('$_PLAY_URL$id', options: _options)
          .then((Response data) {
        String res = _songReg.stringMatch(data.data);
        return List.castFrom(jsonDecode(res)).first;
      });
    } catch (e) {
      return Map();
    }
  }
}
