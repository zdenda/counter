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

    final lightTheme = ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: new AppBarTheme(brightness: Brightness.dark),
    );

    // Dark theme ignores primarySwatch color (https://github.com/flutter/flutter/issues/19089)
    // luckily it uses teal, so no problem here, since app primary color is also teal
    final darkTheme = ThemeData(primarySwatch: Colors.teal, brightness: Brightness.dark);

    return MaterialApp(
      title: 'Counter',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: MyHomePage(title: 'Counter'), // becomes the route named '/'
      routes: {
        DetailPage.ROUTE: (context) => DetailPage(), // '/detail'
      },
    );
  }

}
