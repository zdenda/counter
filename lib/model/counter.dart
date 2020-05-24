import 'counter_repository.dart';


class Counter {

  int _id;
  String _name;
  int _value;
  DateTime _lastEventTime;

  Counter([this._name, this._value = 0, this._id = 0, this._lastEventTime]);

  int get id => _id;
  String get name => _name;
  int get value => _value;
  DateTime get lastEventTime => _lastEventTime;

  void reset() {
    _lastEventTime = null;
    _value = 0;
  }
  int inc() {
    _lastEventTime = DateTime.now();
    return ++_value;
  }
  //TODO: int dec()


  Map<String, dynamic> toMap() {
    return {
      CounterRepository.COL_ID: _id,
      CounterRepository.COL_NAME: _name,
    };
  }

  @override
  String toString() {
    return '${_name ?? '#$id'}: $_value';
  }

}
