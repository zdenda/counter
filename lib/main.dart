import 'package:counter/model/counter.dart';
import 'package:counter/model/counter_repository.dart';
import 'package:counter/utils/extensions.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter',
      theme: ThemeData(
        // This is the theme of application.
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Counter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Counter> _counters = [];

  Future loadCounters() async {
    _counters = await CounterRepository.getAll();
    setState(() => _counters);
  }

  void _showAddCounterDialog() async {
    String counterName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String name;
        return AlertDialog(
          title: const Text('New counter'),
          content: TextField(
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
            onChanged: (value) => name = value,
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(name);
              },
            ),
          ],
        );
      }
    );

    if (!counterName.isNullOrEmpty()) {
      _counters.add(await CounterRepository.create(counterName));
      setState(() => _counters);
    }
  }

  void _removeCounter() async {
    Counter counter = _counters.removeLast();
    await CounterRepository.delete(counter.id);
    setState(() => _counters);
  }

  void _incrementCounter(int counterId) async {
    Counter counter =_counters.firstWhere((counter) => counter.id == counterId);
    await CounterRepository.inc(counter);
    counter.inc();
    setState(() => _counters);
  }

  void _resetCounter(int counterId) async {
    Counter counter =_counters.firstWhere((counter) => counter.id == counterId);
    await CounterRepository.reset(counter.id);
    counter.reset();
    setState(() => _counters);
  }

  @override
  void initState() {
    super.initState();
    loadCounters();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _removeCounter,
          ),
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView.builder(
          itemCount: _counters.length,
          itemBuilder: (context, i) {
            var counter = _counters[i];
            return Card(
              child: ListTile(
                title: Text(
                  '$counter',
                  style: Theme.of(context).textTheme.headline3,
                ),
                onTap: () => _incrementCounter(counter.id),
                onLongPress: () => _resetCounter(counter.id),
              )
            );
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCounterDialog,
        tooltip: 'Add a new Counter',
        child: Icon(Icons.add),
      ),
    );
  }
}
