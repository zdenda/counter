import 'package:flutter/material.dart';
import 'package:counter/model/counter.dart';
import 'package:counter/model/counter_repository.dart';
import 'package:counter/model/event.dart';


class DetailArgs {
  final int counterId;
  final String title;

  DetailArgs(this.counterId, this.title);
}


class DetailPage extends StatefulWidget {
  static const String ROUTE = '/detail';

  static goTo(BuildContext context, Counter counter) {
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

  void _removeCounter(int id) async {
    await CounterRepository.delete(id);
    //TODO: remove counter from home page
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final DetailArgs args = ModalRoute.of(context).settings.arguments;
      //TODO: cancel loading when navigating from page
      _counter = CounterRepository.get(args.counterId);
      _events = CounterRepository.getAllCounterEvents(args.counterId);
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
                /*IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _removeCounter(snapshot.data.id),
                )*/
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
