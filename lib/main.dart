import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'todo.dart';
import 'common.dart';
import 'pages/home.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<Todo>(TodoAdapter());
  Box<Todo> box = await Hive.openBox<Todo>(todosBox);
  Box settings = await Hive.openBox(settingsBox);

  // If the user clears everything and restarts the app, we shouldn't add the
  // defaults back, so we only add them once.
  bool newInstall = !settings.get('defaultsAdded', defaultValue: false);
  if (newInstall && box.isEmpty) {
    resetApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const HomePage(),
    );
  }
}
