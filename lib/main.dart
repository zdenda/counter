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

    final lightTheme = ThemeData(
        primarySwatch: Colors.teal,
        //TODO: Why it was here? it seems to be working without it
        //appBarTheme: new AppBarTheme(brightness: Brightness.dark),
    );

    // Dark theme ignores primarySwatch color (https://github.com/flutter/flutter/issues/19089)
    // luckily it uses teal, so no problem here, since app primary color is also teal
    final darkTheme = ThemeData(primarySwatch: Colors.teal, brightness: Brightness.dark);

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
