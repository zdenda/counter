import 'package:counter/model/app_model.dart';
import 'package:counter/model/objects/counter.dart';
import 'package:counter/model/objects/event.dart';
import 'package:counter/utils/extensions.dart';
import 'package:counter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';


class Dialogs {

  static void showEditDialog(BuildContext context, Counter? counter) async {
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

  static void showRemoveDialog(BuildContext context, Counter? counter) async {
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

  static void showDeleteEventDialog(BuildContext context, Event event) async {
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

  static void showEditNoteDialog(BuildContext context, Event event) async {
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

  static void showEditNoteTimeDialog(BuildContext context, Event event) async {
    final appModel = Provider.of<AppModel>(context, listen: false);

    pickDate(DateTime initialDate, void Function(DateTime) onDatePicked) => {
          showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now())
              .then((value) => {if (value != null) onDatePicked(value)})
        };

    pickTime(DateTime initialDate, void Function(TimeOfDay) onTimePicked) => {
          showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(initialDate),
          ).then((value) => {if (value != null) onTimePicked(value)})
        };

    DateTime? time = await showDialog<DateTime>(
        context: context,
        builder: (BuildContext context) {
          DateTime result = event.time.copy();
          return AlertDialog(
            title: const Text('Edit event time'),
            content: StatefulBuilder(builder: (context, setState) {
              return Column(children: [
                InkWell(
                    onTap: () =>
                        pickDate(result, (date) => setState(() => result = result.applyDate(date))),
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(Jiffy(result).yMMMd),
                          const Icon(Icons.edit, size: 18)
                        ]))),
                InkWell(
                    onTap: () =>
                        pickTime(result, (time) => setState(() => result = result.applyTime(time))),
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [Text(Jiffy(result).Hm), const Icon(Icons.edit, size: 18)]))),
              ]);
            }),
            scrollable: true,
            actions: [
              MyTextButton(text: 'CANCEL', onPressed: () => Navigator.of(context).pop()),
              MyTextButton(text: 'OK', onPressed: () => Navigator.of(context).pop(result))
            ],
          );
        });

    if (time != null) {
      await appModel.updateTime(event, time);
    }
  }

}
