import 'counter_repository.dart';


class Counter {

  int _id;
  String _name;
  int _value;

  Counter([this._name, this._value = 0, this._id = 0]);

  int get id => _id;

  void reset() => _value = 0;
  int inc() => ++_value;
  int dec() => --_value;


  Map<String, dynamic> toMap() {
    return {
      CounterRepository.COL_ID: _id,
      CounterRepository.COL_NAME: _name,
      CounterRepository.COL_VALUE: _value,
    };
  }

  @override
  String toString() {
    return '${_name ?? '#$id'}: $_value';
  }

}
