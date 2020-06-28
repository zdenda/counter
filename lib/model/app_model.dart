import 'dart:collection';

import 'package:counter/model/objects/event.dart';
import 'package:counter/model/repository.dart';
import 'package:flutter/foundation.dart';

import 'objects/counter.dart';


class AppModel extends ChangeNotifier {

  final Map<int, List<Event>> _events = {};
  List<Counter> _counters = [];

  Future<UnmodifiableListView<Counter>> get counters async {
    if (_counters.isEmpty) {
      _counters = await Repository.getAll();
    }
    return UnmodifiableListView(_counters);
  }

  Future<Counter> getCounter(counterId) async {
    return (await counters).firstWhere((counter) => counter.id == counterId);
  }

  Future<UnmodifiableListView<Event>> getEvents(int counterId) async {
    if (!_events.containsKey(counterId)) {
      _events[counterId] = await Repository.getAllCounterEvents(counterId);
    }
    return UnmodifiableListView(_events[counterId]);
  }

  Future<Counter> createCounter(String name) async {
    final counter = await Repository.create(name);
    _counters.add(counter);
    notifyListeners();
    return counter;
  }

  Future<void> updateCounter(Counter counter) async {
    var index = _counters.indexWhere((c) => c.id == counter.id);
    _counters[index] = counter;
    await Repository.update(counter);
    notifyListeners();
    return;
  }

  Future<void> deleteCounter(Counter counter) async {
    await Repository.delete(counter.id);
    notifyListeners();
    return;
  }

  Future<void> incCounter(int counterId) async {
    _events.remove(counterId);
    var counter = _counters.firstWhere((counter) => counter.id == counterId);
    counter.inc();
    //_counters.sort((a, b) => b.lastEventTime != null ? b.lastEventTime.compareTo(a.lastEventTime) : -1);
    await Repository.inc(counter);
    notifyListeners();
    return;
  }

  forceUpdate() {
    _counters.clear();
    _events.clear();
    notifyListeners();
  }

}
