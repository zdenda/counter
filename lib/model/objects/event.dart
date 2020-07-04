
class Event {

  int _id;
  DateTime _time;
  String note;

  Event(this._id, this._time, this.note);

  int get id => _id;
  DateTime get time => _time;

}
