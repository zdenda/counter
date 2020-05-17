import 'counter_repository.dart';


class Counter {

  int _id;
  String _name;
  int _value;

  Counter([this._name, this._value = 0, this._id = 0]);

  int get id => _id;
  String get name => _name;
  int get value => _value;

  void reset() => _value = 0;
  int inc() => ++_value;
  //TODO: int dec() => --_value;


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
