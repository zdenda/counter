import 'package:counter/model/counter.dart';
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
  List<Counter> _counters = [new Counter("Counter")];

  void _addCounter() {
    setState(() => _counters.add(new Counter()));
  }

  void _removeCounter() {
    setState(() => _counters.removeLast());
  }

  void _incrementCounter(int counterId) {
    setState(() {
      _counters.firstWhere((counter) => counter.id == counterId).inc();
    });
  }

  void _resetCounter(int counterId) {
    setState(() {
      _counters.firstWhere((counter) => counter.id == counterId).reset();
    });
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
                  style: Theme.of(context).textTheme.display2,
                ),
                onTap: () => _incrementCounter(counter.id),
                onLongPress: () => _resetCounter(counter.id),
              )
            );
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCounter,
        tooltip: 'Add a new Counter',
        child: Icon(Icons.add),
      ),
    );
  }
}
