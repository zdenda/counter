import 'dart:convert';
import 'dart:io';

import 'package:counter/model/app_model.dart';
import 'package:counter/model/objects/counter.dart';
import 'package:counter/model/objects/event.dart';
import 'package:counter/model/repository.dart';
import 'package:counter/utils/extensions.dart';
import 'package:counter/utils/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';


enum DialogResult { export, import }


class Dialogs {

  static void showAddCounterDialog(BuildContext context) async {
    final appModel = Provider.of<AppModel>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    String? counterName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          String? name;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('New counter'),
              content: TextField(
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) => setState(() => name = value.trim()),
              ),
              actions: <Widget>[
                MyTextButton(
                  text: 'CANCEL',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                MyTextButton(
                    text: 'OK',
                    onPressed: !name.isNullOrEmpty() ? () => Navigator.of(context).pop(name) : null
                ),
              ],
            );
          });
        });

    if (!counterName.isNullOrEmpty()) {
      await appModel.createCounter(counterName);
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('New counter "$counterName" was created!'))
      );
    }
  }

  static void showAboutAppDialog(context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Image.asset('assets/icon/ic_launcher.png', height: 60, width: 60),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Counter', style: Theme.of(context).textTheme.headline4),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                      return Text('Version: ${snapshot.hasData ? snapshot.data!.version : '…'}',
                          style: Theme.of(context).textTheme.headline6);
                    },
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              MyTextButton(text: 'OK', onPressed: () => Navigator.of(context).pop()),
            ],
          );
        }
    );
  }

  static void showExportDialog(BuildContext context, AppModel appModel) async {
    switch (await showDialog<DialogResult>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select export or import'),
            children: <Widget>[
              SimpleDialogOption(
                  child: const Text('Export'),
                  onPressed: () => Navigator.pop(context, DialogResult.export)
              ),
              SimpleDialogOption(
                child: const Text('Import'),
                onPressed: () => Navigator.pop(context, DialogResult.import),
              ),
            ],
          );
        })) {
      case DialogResult.export:
        if (await _exportData()) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('App data were exported to a file.'))
          );
        }
        break;
      case DialogResult.import:
        if (await _importData()) {
          appModel.forceUpdate();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Application data were imported.'))
          );
        }
        break;
      default:
        // dialog dismissed
        break;
    }
  }

}


Future<bool> _exportData() async {
  Directory tempDir = await getTemporaryDirectory();
  final String date = Jiffy().format("yyyy-MM-dd");
  File exportFile = File('${tempDir.path}/counter-data-export_$date.json');

  List<Map<String, dynamic>> data = [];

  final List<Counter> counters = await Repository.getAll();
  await Future.forEach(counters, (dynamic counter) async {
    List<Event> events = await Repository.getAllCounterEvents(counter.id);
    events.sort((a, b) => a.id!.compareTo(b.id!)); // sort events by IDs
    Map<String, dynamic> map = counter.toJson();
    map['events'] = events;
    data.add(map);
  });

  await exportFile.writeAsString(jsonEncode(data));

  await Share.shareXFiles([XFile(exportFile.path, mimeType: "application/json")],
      subject: "Counter data export");

  return true;
}

Future<bool> _importData() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result == null) return false; // User canceled the picker

  File file = File(result.files.single.path!);

  List<dynamic> data = jsonDecode(await file.readAsString());
  await Future.forEach(data, (dynamic element) async {
    Map<String, dynamic> counterData = element as Map<String, dynamic>;
    Counter c = Counter.fromJson(counterData);
    Counter counter = await Repository.create(c.name);

    await Future.forEach(counterData['events'], (dynamic element) async {
      Map<String, dynamic> eventData = element as Map<String, dynamic>;
      Event e = Event.fromJson(eventData);
      await Repository.createEvent(counter, e.time, e.note);
    });

  });

  return true;
}
