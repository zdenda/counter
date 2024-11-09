import 'package:counter/model/app_model.dart';
import 'package:counter/pages/detail/detail.dart';
import 'package:flutter/material.dart';
import 'package:counter/pages/home/home.dart';
import 'package:provider/provider.dart';


void main() => runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppModel())
      ],
      child: const MyApp(),
    ),
);


class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    const colorSchemeSeed = Colors.teal;

    final lightTheme = ThemeData(colorSchemeSeed: colorSchemeSeed);
    final darkTheme = ThemeData(
        colorSchemeSeed: colorSchemeSeed, brightness: Brightness.dark
    );

    return MaterialApp(
      title: 'Counter',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'Counter'), // becomes the route named '/'
      routes: {
        DetailPage.ROUTE: (context) => const DetailPage(), // '/detail'
      },
    );
  }

}
