import 'package:counter/model/repository.dart';
import 'package:counter/model/objects/counter.dart';
import 'package:counter/pages/detail.dart';
import 'package:counter/utils/extensions.dart';
import 'package:flutter/material.dart';


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
    _counters = await Repository.getAll();
    setState(() => _counters);
  }

  void _showAddCounterDialog() async {
    String counterName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          String name;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('New counter'),
              content: TextField(
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                onChanged: (value) => setState(() => name = value.trim()),
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
                  onPressed: name.isNullOrEmpty()
                      ? null
                      : () {
                          Navigator.of(context).pop(name);
                        },
                ),
              ],
            );
          });
        });

    if (!counterName.isNullOrEmpty()) {
      _counters.add(await Repository.create(counterName));
      setState(() => _counters);
    }
  }

  void _incrementCounter(int counterId) async {
    Counter counter = _counters.firstWhere((counter) => counter.id == counterId);
    await Repository.inc(counter);
    counter.inc();
    //_counters.sort((a, b) => b.lastEventTime != null ? b.lastEventTime.compareTo(a.lastEventTime) : -1);
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
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView.builder(
            itemCount: _counters.length,
            itemBuilder: (context, i) {
              var counter = _counters[i];
              return Card(
                child: InkWell(
                  onTap: () => DetailPage.goTo(context, counter).then((_) => loadCounters()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text('${counter.name}',
                                    style: Theme.of(context).textTheme.headline4),
                              ),
                              if (counter.lastEventTime != null)
                                FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text('Last: ${counter.lastEventTime}',
                                      style: Theme.of(context).textTheme.caption),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
                          child:
                          Text('${counter.value}', style: Theme.of(context).textTheme.headline3),
                        ),
                        Ink(
                          decoration: const ShapeDecoration(
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            iconSize: 36,
                            icon: Icon(Icons.add_circle_outline),
                            color: Theme.of(context).accentColor,
                            onPressed: () => _incrementCounter(counter.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCounterDialog,
        tooltip: 'Add a new Counter',
        child: Icon(Icons.add),
      ),
    );
  }

}
