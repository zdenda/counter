import 'package:counter/model/repository.dart';
import 'package:counter/model/objects/counter.dart';
import 'package:counter/model/objects/event.dart';
import 'package:counter/utils/extensions.dart';
import 'package:flutter/material.dart';


class DetailArgs {
  final int counterId;
  final String title;

  DetailArgs(this.counterId, this.title);
}


class DetailPage extends StatefulWidget {
  static const String ROUTE = '/detail';

  static Future<T> goTo<T extends Object>(BuildContext context, Counter counter) {
    //TODO: try https://stackoverflow.com/questions/50818770/passing-data-to-a-stateful-widget
    return Navigator.pushNamed(context, DetailPage.ROUTE,
        arguments: DetailArgs(counter.id, counter.name));
  }

  DetailPage({Key key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}


class _DetailPageState extends State<DetailPage> {

  Future<Counter> _counter;
  Future<List<Event>> _events;

  _showEditDialog(Counter counter) async {
    Counter newCounter = await showDialog<Counter>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit counter'),
              content: TextFormField(
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                initialValue: counter.name,
                onChanged: (value) {
                  value = value.trim();
                  if (!value.isNullOrEmpty()) counter.name = value;
                },
              ),
              actions: <Widget>[
                FlatButton(
                  child: const Text('CANCEL'),
                  onPressed: () => Navigator.of(context).pop()
                ),
                FlatButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(counter)
                ),
              ],
            );
          });
        });

    if (newCounter != null) {
      await Repository.update(newCounter);
      _counter = Repository.get(newCounter.id);
      _counter.whenComplete(() => setState(() {}));
    }
  }

  void _removeCounter(Counter counter) async {
    bool result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Remove this counter?'),
            //content: Text("Permanently remove the counter \"${counter.name}\"?"),
            actions: <Widget>[
              FlatButton(
                  child: const Text('CANCEL'),
                  onPressed: () => Navigator.of(context).pop(false)
              ),
              FlatButton(
                  child: const Text('REMOVE'),
                  onPressed: () => Navigator.of(context).pop(true)
              ),
            ],
          );
        }
    );

    if (result == true) {
      await Repository.delete(counter.id);
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final DetailArgs args = ModalRoute.of(context).settings.arguments;
      //TODO: cancel loading when navigating from page
      _counter = Repository.get(args.counterId);
      _events = Repository.getAllCounterEvents(args.counterId);
      Future.wait([_counter]).whenComplete(() => setState(() {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    final DetailArgs args = ModalRoute.of(context).settings.arguments;
    return FutureBuilder<Counter>(
      future: _counter,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data.name),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(snapshot.data),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _removeCounter(snapshot.data),
                )
              ],
            ),
            body: Container(
              child: FutureBuilder<List<Event>>(
                future: _events,
                builder: (context, snapshot) {
                  if (snapshot.hasError ||
                      (snapshot.hasData && snapshot.data.isEmpty) ||
                      snapshot.data == null) {
                    return Text('${snapshot.error ?? ''}');
                  } else {
                    return Column(
                      children: <Widget>[
                        Text('${snapshot.data.length}',
                            style: Theme.of(context).textTheme.headline3),
                        Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              var event = snapshot.data[index];
                              return ListTile(
                                title: Text(
                                  '${event.time}',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('${args.title}…'),
          ),
          body: Center(
            child: snapshot.hasError ? Text("${snapshot.error}") : CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
