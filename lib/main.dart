import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'todo.dart';
import 'common.dart';
import 'pages/home.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<Todo>(TodoAdapter());
  Box<Todo> todos = await Hive.openBox<Todo>(todosBox);
  Box settings = await Hive.openBox(settingsBox);

  // If the user clears everything and restarts the app, we shouldn't add the
  // defaults back, so we only add them once.
  bool newInstall = !settings.get('defaultsAdded', defaultValue: false);
  if (newInstall && todos.isEmpty) {
    resetApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(settingsBox).listenable(),
      builder: (BuildContext context, Box settings, _) {
        bool darkMode = settings.get('darkMode', defaultValue: false);
        return MaterialApp(
          title: 'Todos',
          themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
          darkTheme: ThemeData.from(
            colorScheme: const ColorScheme.dark(
              primary: Colors.deepOrange,
              primaryVariant: Colors.deepOrangeAccent,
            ),
          ),
          theme: ThemeData(
            primarySwatch: Colors.deepOrange,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
