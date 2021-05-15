import 'package:counter/model/app_model.dart';
import 'package:counter/pages/detail.dart';
import 'package:flutter/material.dart';
import 'package:counter/pages/home.dart';
import 'package:provider/provider.dart';


void main() => runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppModel())
      ],
      child: MyApp(),
    ),
);


class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter',
      theme: ThemeData(
        // This is the theme of application.
        primarySwatch: Colors.teal,
        appBarTheme: new AppBarTheme(brightness: Brightness.dark)
      ),
      home: MyHomePage(title: 'Counter'), // becomes the route named '/'
      routes: {
        DetailPage.ROUTE: (context) => DetailPage(), // '/detail'
      },
    );
  }

}
