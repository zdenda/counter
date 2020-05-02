
class Counter {

  static int lastId = 0;

  int _id;
  String _name;
  int _value;

  Counter([this._name, this._value = 0]) {
    this._id = Counter.lastId++;
  }

  int get id => _id;

  void reset() => _value = 0;
  int inc() => ++_value;
  int dec() => --_value;

  @override
  String toString() {
    return '${_name ?? '#$id'}: $_value';
  }

}
