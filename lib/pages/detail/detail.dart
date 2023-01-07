import 'package:counter/model/app_model.dart';
import 'package:counter/model/objects/counter.dart';
import 'package:counter/model/objects/event.dart';
import 'package:counter/pages/detail/dialogs.dart';
import 'package:counter/utils/extensions.dart';
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

  const DetailPage({Key? key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}


class _DetailPageState extends State<DetailPage> {

  _incrementCounter(int? counterId) async {
    final appModel = Provider.of<AppModel>(context, listen: false);
    await appModel.incCounter(counterId);
  }

  Widget _counterDetail(BuildContext context, AppModel appModel, Counter counter) {
    return Scaffold(
      appBar: AppBar(
        title: Text(counter.name),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Dialogs.showEditDialog(context, counter),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => Dialogs.showRemoveDialog(context, counter),
          )
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: appModel.getEvents(counter.id),
        builder: (context, snapshot) {
          if (snapshot.hasError ||
              (snapshot.hasData && snapshot.data!.isEmpty) ||
              snapshot.data == null) {
            return Text('${snapshot.error ?? ''}');
          } else {
            List<Event> events = snapshot.data!;
            return Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  color: Theme.of(context).primaryColorLight,
                  child: Text('${events.length}', style: Theme.of(context).textTheme.headline3),
                ),
                Expanded(
                  child: _eventsListView(events),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.plus_one),
        onPressed: () => _incrementCounter(counter.id),
      ),
    );
  }

  Widget _eventsListView(List<Event> events) {
    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        Event event = events[index];
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
          subtitle: event.note.isNullOrEmpty() ? null : Text(event.note!),
          trailing: IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => Dialogs.showDeleteEventDialog(context, event),
          ),
          onTap: () => Dialogs.showEditNoteDialog(context, event),
          onLongPress: () => Dialogs.showEditNoteTimeDialog(context, event),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final DetailArgs args = ModalRoute.of(context)!.settings.arguments as DetailArgs;
    return Consumer<AppModel>(
      builder: (context, appModel, child) {
        return FutureBuilder<Counter>(
          future: appModel.getCounter(args.counterId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _counterDetail(context, appModel, snapshot.data!);
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: Text('${args.title}…'),
                ),
                body: Center(
                  child:
                      snapshot.hasError
                          ? Text("${snapshot.error}")
                          : const CircularProgressIndicator(),
                ),
              );
            }
          },
        );
      },
    );
  }

}
