class SongModel {
  final String id;
  final int type;
  final String name;
  final String singers;
  final bool collected;
  
  SongModel({
    this.id,
    this.name,
    this.type,
    this.singers,
    this.collected,
  });

  SongModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        type = json['type'],
        singers = json['singers'],
        collected = json['collected'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'type': type,
        'singers': singers,
        'collected': collected,
      };
}
