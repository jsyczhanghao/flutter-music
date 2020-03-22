class SongSourceModel {
  final String id;
  final int type;
  final String file;
  final String lrc;
  final String img;
  final int duration;

  SongSourceModel({
    this.id,
    this.type,
    this.file,
    this.lrc,
    this.img,
    this.duration,
  });

  SongSourceModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        type = json['type'],
        file = json['file'],
        lrc = json['lrc'],
        img = json['img'],
        duration = json['duration'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type,
        'file': file,
        'lrc': lrc,
        'img': img,
        'duration': duration,
      };
}
