import 'package:counter/model/app_model.dart';
import 'package:counter/model/objects/counter.dart';
import 'package:counter/model/objects/event.dart';
import 'package:counter/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';


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

  _showEditDialog(Counter counter) async {
    Counter editedCounter = await showDialog<Counter>(
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

    if (editedCounter != null) {
      final appModel = Provider.of<AppModel>(context, listen: false);
      await appModel.updateCounter(editedCounter);
    }
  }

  void _showRemoveDialog(Counter counter) async {
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
      final appModel = Provider.of<AppModel>(context, listen: false);
      await appModel.deleteCounter(counter);
      Navigator.pop(context);
    }
  }

  void _showDeleteEventDialog(Event event) async {
    bool result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Remove event?'),
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
      final appModel = Provider.of<AppModel>(context, listen: false);
      await appModel.deleteEvent(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DetailArgs args = ModalRoute.of(context).settings.arguments;
    return Consumer<AppModel>(
      builder: (context, appModel, child) {
        return FutureBuilder<Counter>(
          future: appModel.getCounter(args.counterId),
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
                      onPressed: () => _showRemoveDialog(snapshot.data),
                    )
                  ],
                ),
                body: Container(
                  child: FutureBuilder<List<Event>>(
                    future: appModel.getEvents(args.counterId),
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
                              child: ListView.separated(
                                itemCount: snapshot.data.length,
                                separatorBuilder: (context, index) => Divider(),
                                itemBuilder: (context, index) {
                                  var event = snapshot.data[index];
                                  var now = DateTime.now();
                                  return ListTile(
                                    title: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        '${Jiffy(event.time).format(event.time.year == now.year
                                            ? 'EEE, MMM d HH:mm'
                                            : 'MMM d, yyyy')} • ${Jiffy(event.time).fromNow()}',
                                        style: Theme.of(context).textTheme.headline5,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete_forever),
                                      onPressed: () => _showDeleteEventDialog(event),
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
      },
    );
  }

}
