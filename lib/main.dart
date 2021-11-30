import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'todo.dart';

const todosBox = 'todo';
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

  await todos.clear();

  for (Todo todo in makeDefaultTodos()) {
    todos.add(todo);
  }

  settings.put('defaultsAdded', true);
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
      home: const MyHomePage(title: 'Todos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _newTodoText = '';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Todo>(todosBox).listenable(),
      builder: (context, Box<Todo> box, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
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
              itemCount: box.length,
              itemBuilder: (context, i) {
                Todo todo = box.getAt(i)!;
                return ListTile(
                  title: Text(todo.text),
                  trailing: Icon(
                    todo.done ? Icons.check_box : Icons.check_box_outline_blank,
                    color: todo.done ? Colors.green : null,
                    semanticLabel: todo.done ? 'Mark Not Done' : 'Mark Done',
                  ),
                  onTap: () {
                    todo.toggleDone();
                    todo.save();
                  },
                  onLongPress: () {
                    box.deleteAt(i);
                  },
                );
              },
              separatorBuilder: (context, i) {
                return const Divider();
              }
            ),
          ),
          floatingActionButton: FloatingActionButton(
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
                                  box.add(Todo(_newTodoText));
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
            tooltip: 'New',
            child: const Icon(Icons.add),
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
        builder: (context, Box box, _) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                )
              ],
            ),
          );
        }
      )
    );
  }
}
