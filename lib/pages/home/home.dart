import 'dart:collection';

import 'package:counter/model/app_model.dart';
import 'package:counter/model/objects/counter.dart';
import 'package:counter/pages/detail/detail.dart';
import 'package:counter/pages/home/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';


class MyHomePage extends StatefulWidget {

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();

}


class _MyHomePageState extends State<MyHomePage> {

  void _incrementCounter(int? counterId) async {
    final appModel = Provider.of<AppModel>(context, listen: false);
    await appModel.incCounter(counterId);
  }

  List<Widget> _appBarActions(AppModel appModel) {
    return <Widget>[
      PopupMenuButton<Function>(
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<Function>(
                  child: const Text('Export / Import'),
                  value: () => Dialogs.showExportDialog(context, appModel)
              ),
              PopupMenuItem<Function>(
                  child: const Text('About'),
                  value: () => Dialogs.showAboutAppDialog(context)
              ),
            ];
          },
          onSelected: (value) => value.call()
      ),
    ];
  }

  Widget _emptyList(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Text(
          "Tap on the + button to create a new counter.",
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        )
    );
  }

  Widget _listView(UnmodifiableListView<Counter> data) {
    return ListView.builder(
        // use key to force rebuild of the list when dark/light mode is switched,
        // to use proper colors for texts in cards
        key: ValueKey(MediaQuery.of(context).platformBrightness),
        itemCount: data.length,
        itemBuilder: (context, index) => _listItem(context, data[index])
    );
  }

  Widget _listItem(BuildContext context, Counter counter) {
    return Card(
        child: InkWell(
          onTap: () => DetailPage.goTo(context, counter),
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
                        child: Text(
                            counter.name,
                            style: Theme.of(context).textTheme.headlineMedium
                        ),
                      ),
                      if (counter.lastEventTime != null)
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text('Last time: ${Jiffy.parseFromDateTime(counter.lastEventTime!).fromNow()}',
                              style: Theme.of(context).textTheme.bodySmall
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
                  child: Text('${counter.value}',
                      style: Theme.of(context).textTheme.displaySmall
                  ),
                ),
                Ink(
                  decoration: const ShapeDecoration(shape: CircleBorder()),
                  child: IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.add_circle_outline),
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () => _incrementCounter(counter.id),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Consumer<AppModel>(builder: (context, appModel, child) {
      return Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
            actions: _appBarActions(appModel),
          ),
          body: Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: FutureBuilder<UnmodifiableListView<Counter>>(
                  future: appModel.counters,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    } else if (snapshot.hasData) {
                      var data = snapshot.requireData;
                      return data.isEmpty ? _emptyList(context): _listView(data);
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }
              )
          ),
          floatingActionButton: Builder(
            builder: (BuildContext context) {
              return FloatingActionButton(
                onPressed: () => Dialogs.showAddCounterDialog(context),
                tooltip: 'Create a new Counter',
                child: const Icon(Icons.add),
              );
            },
          )
      );
    });
  }

}
