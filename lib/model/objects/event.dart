import 'dart:convert';


class Event {

  final int? _id;
  DateTime time;
  String? note;

  Event(this._id, this.time, this.note);

  int? get id => _id;

  Event.fromJson(Map<String, dynamic> json)
      : _id = json['id'],
        time = DateTime.parse(json['time']),
        note = json['note'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': time.toIso8601String(),
    'note': note,
  };

  @override
  String toString() {
    return jsonEncode(toJson());
  }

}
