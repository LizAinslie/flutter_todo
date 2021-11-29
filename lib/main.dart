import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'todo.dart';

const todosBox = 'todo';
List<Todo> defaultTodos = [
  Todo('This is a todo list app'),
  Todo('Use the button below to add things'),
  Todo('Tap an item to mark it done'),
  Todo('Tap it again to mark it undone'),
  Todo('Finally, tap and hold an item to remove it')
];

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<Todo>(TodoAdapter());
  Box box = await Hive.openBox<Todo>(todosBox);

  if (box.isEmpty) {
    for (Todo todo in defaultTodos) {
      box.add(todo);
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
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
                                )
                              )
                            ],
                          ),
                        )
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
