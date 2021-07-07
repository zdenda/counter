import 'package:counter/model/app_model.dart';
import 'package:counter/model/objects/counter.dart';
import 'package:counter/model/objects/event.dart';
import 'package:counter/utils/extensions.dart';
import 'package:counter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';


class DetailArgs {
  final int? counterId;
  final String title;

  DetailArgs(this.counterId, this.title);
}


class DetailPage extends StatefulWidget {
  static const String ROUTE = '/detail';

  static Future<T?> goTo<T extends Object?>(BuildContext context, Counter counter) {
    //TODO: try https://stackoverflow.com/questions/50818770/passing-data-to-a-stateful-widget
    return Navigator.pushNamed(context, DetailPage.ROUTE,
        arguments: DetailArgs(counter.id, counter.name));
  }

  DetailPage({Key? key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}


class _DetailPageState extends State<DetailPage> {

  _incrementCounter(int? counterId) async {
    final appModel = Provider.of<AppModel>(context, listen: false);
    await appModel.incCounter(counterId);
  }

  _showEditDialog(Counter? counter) async {
    Counter? editedCounter = await showDialog<Counter>(
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
                initialValue: counter!.name,
                onChanged: (value) {
                  value = value.trim();
                  if (!value.isNullOrEmpty()) counter.name = value;
                },
              ),
              actions: <Widget>[
                MyTextButton(text: 'CANCEL', onPressed: () => Navigator.of(context).pop()),
                MyTextButton(text: 'OK', onPressed: () => Navigator.of(context).pop(counter)),
              ],
            );
          });
        });

    if (editedCounter != null) {
      final appModel = Provider.of<AppModel>(context, listen: false);
      await appModel.updateCounter(editedCounter);
    }
  }

  void _showRemoveDialog(Counter? counter) async {
    bool? result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Remove this counter?'),
            //content: Text("Permanently remove the counter \"${counter.name}\"?"),
            actions: <Widget>[
              MyTextButton(text: 'CANCEL', onPressed: () => Navigator.of(context).pop(false)),
              MyTextButton(text: 'REMOVE', onPressed: () => Navigator.of(context).pop(true)),
            ],
          );
        }
    );

    if (result == true) {
      final appModel = Provider.of<AppModel>(context, listen: false);
      await appModel.deleteCounter(counter!);
      Navigator.pop(context);
    }
  }

  void _showDeleteEventDialog(Event event) async {
    bool? result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Remove event?'),
            //content: Text("Permanently remove the counter \"${counter.name}\"?"),
            actions: <Widget>[
              MyTextButton(text: 'CANCEL', onPressed: () => Navigator.of(context).pop(false)),
              MyTextButton(text: 'REMOVE', onPressed: () => Navigator.of(context).pop(true)),
            ],
          );
        }
    );

    if (result == true) {
      final appModel = Provider.of<AppModel>(context, listen: false);
      await appModel.deleteEvent(event);
    }
  }

  _showEditNoteDialog(Event event) async {
    String? note = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          String? result;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit event note'),
              content: TextFormField(
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Note',
                ),
                initialValue: event.note ?? "",
                onChanged: (value) {
                  result = value.trim();
                },
              ),
              actions: <Widget>[
                MyTextButton(text: 'CANCEL', onPressed: () => Navigator.of(context).pop()),
                MyTextButton(text: 'OK', onPressed: () => Navigator.of(context).pop(result)),
              ],
            );
          });
        });

    if (note != null) {
      final appModel = Provider.of<AppModel>(context, listen: false);
      await appModel.addNote(event, note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DetailArgs? args = ModalRoute.of(context)!.settings.arguments as DetailArgs?;
    return Consumer<AppModel>(
      builder: (context, appModel, child) {
        return FutureBuilder<Counter>(
          future: appModel.getCounter(args!.counterId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(snapshot.data!.name),
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
                          (snapshot.hasData && snapshot.data!.isEmpty) ||
                          snapshot.data == null) {
                        return Text('${snapshot.error ?? ''}');
                      } else {
                        return Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              color: Theme.of(context).primaryColorLight,
                              child: Text('${snapshot.data!.length}',
                                style: Theme.of(context).textTheme.headline3),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemCount: snapshot.data!.length,
                                separatorBuilder: (context, index) => Divider(),
                                itemBuilder: (context, index) {
                                  var event = snapshot.data![index];
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
                                    subtitle: !event.note.isNullOrEmpty() ? Text(event.note!) : null,
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete_forever),
                                      onPressed: () => _showDeleteEventDialog(event),
                                    ),
                                    onTap: () => _showEditNoteDialog(event),
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
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.plus_one),
                  onPressed: () => _incrementCounter(snapshot.data!.id),
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
