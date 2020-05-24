import 'package:flutter/material.dart';
import 'package:counter/pages/home.dart';

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
