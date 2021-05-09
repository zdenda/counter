import '../repository.dart';


class Counter {

  int _id;
  String _name;
  int _value;
  DateTime _lastEventTime;

  Counter([this._name, this._value = 0, this._id = 0, this._lastEventTime]);

  int get id => _id;
  String get name => _name ?? '#$id';
  int get value => _value;
  DateTime get lastEventTime => _lastEventTime;

  set name(String name) => _name = name;


  void reset() {
    _lastEventTime = null;
    _value = 0;
  }
  int inc() {
    _lastEventTime = DateTime.now();
    return ++_value;
  }
  //TODO: int dec()


  //TODO: create a special class with all repository "converters"
  Map<String, dynamic> toMap() {
    return {
      Repository.COL_ID: _id,
      Repository.COL_NAME: _name,
    };
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };

  @override
  String toString() {
    return '${_name ?? '#$id'}: $_value';
  }

}
