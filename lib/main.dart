import 'package:flutter/material.dart';
import 'package:flutter_todo/components/todo_item.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'todo.dart';

const settingsBox = 'settings';

List<Todo> makeDefaultTodos() => [
  Todo('This is a todo list app'),
  Todo('Use the button below to add things'),
  Todo('Tap an item to mark it done'),
  Todo('Tap it again to mark it undone'),
  Todo('Finally, tap and hold an item to remove it')
];

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

void resetApp() async {
  Box<Todo> todos = Hive.box<Todo>(todosBox);
  Box settings = Hive.box(settingsBox);

  // Apply the default list of tasks
  await todos.clear();
  for (Todo todo in makeDefaultTodos()) {
    todos.add(todo);
  }

  // Settings
  settings.put('defaultsAdded', true); // Tell the app not to create defaults anymore
  settings.put('darkMode', false); // Default: Light mode
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _newTodoText = '';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Todo>(todosBox).listenable(),
      builder: (context, Box<Todo> todos, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Todos'),
            actions: [
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              onChanged: (text) {
                                setState(() {
                                  _newTodoText = text;
                                });
                              },
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    child: const Text('Add'),
                                    onPressed: () {
                                      todos.add(Todo(_newTodoText));
                                      Navigator.pop(context);
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: ElevatedButton(
                                      child: const Text('Cancel'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.add)
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                },
                icon: const Icon(Icons.settings),
              )
            ],
          ),
          body: Center(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: todos.length,
              itemBuilder: (context, i) => TodoItem(task: todos.getAt(i)!),
              separatorBuilder: (context, i) {
                return const Divider();
              }
            ),
          ),
        );
      },
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(settingsBox).listenable(),
        builder: (context, Box settings, _) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Dark Mode'),
                  trailing: Icon(
                    settings.get('darkMode', defaultValue: false) ? Icons.check_box : Icons.check_box_outline_blank,
                    semanticLabel: settings.get('darkMode', defaultValue: false) ? 'Disable Dark Mode' : 'Enable Dark Mode',
                  ),
                  onTap: () {
                    settings.put('darkMode', !settings.get('darkMode', defaultValue: false));
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            height: 200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Warning!',
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                Text('This will remove any existing tasks',
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        child: const Text('I Understand'),
                                        onPressed: () {
                                          resetApp();
                                          Navigator.pop(context);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16),
                                        child: ElevatedButton(
                                          child: const Text('Cancel'),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Text('Reset Todos'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
