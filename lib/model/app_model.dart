import 'dart:collection';

import 'package:counter/model/repository.dart';
import 'package:flutter/foundation.dart';

import 'objects/counter.dart';


class AppModel extends ChangeNotifier {

  final List<Counter> _counters = [];

  Future<UnmodifiableListView<Counter>> get counters async {
    if (_counters.isEmpty) {
      _counters.addAll(await Repository.getAll());
    }
    return UnmodifiableListView(_counters);
  }

  Future<Counter> createCounter(String name) async {
    final counter = await Repository.create(name);
    _counters.add(counter);
    notifyListeners();
    return counter;
  }

  Future<void> incCounter(int counterId) async {
    var counter = _counters.firstWhere((counter) => counter.id == counterId);
    counter.inc();
    //_counters.sort((a, b) => b.lastEventTime != null ? b.lastEventTime.compareTo(a.lastEventTime) : -1);
    await Repository.inc(counter);
    notifyListeners();
    return;
  }

  forceUpdate() {
    _counters.clear();
    notifyListeners();
  }

}
