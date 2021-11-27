import 'package:flutter/material.dart';

void main() {
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


class Todo {
  Todo({required this.text});
  bool done = false;
  String text;

  void toggleDone() {
    done = !done;
  }

  void setText(String text) {
    this.text = text;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _todos = <Todo>[
    Todo(text: 'This is a todo list app'),
    Todo(text: 'Use the button below to add things'),
    Todo(text: 'Tap an item to mark it done'),
    Todo(text: 'Tap it again to mark it undone'),
    Todo(text: 'Finally, tap and hold an item to remove it')

  ];
  String _newTodoText = '';

  Widget _buildRow(int index) {
    Todo todo = _todos[index];
    return ListTile(
      title: Text(todo.text),
      trailing: Icon(
        todo.done ? Icons.check_box : Icons.check_box_outline_blank,
        color: todo.done ? Colors.green : null,
        semanticLabel: todo.done ? 'Mark Not Done' : 'Mark Done',
      ),
      onTap: () {
        setState(() {
          _todos[index].toggleDone();
        });
      },
      onLongPress: () {
        setState(() {
          _todos.removeAt(index);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child:
        ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: _todos.length,
          itemBuilder: (context, i) {
            return _buildRow(i);
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
                              setState(() {
                                _todos.add(Todo(text: _newTodoText));
                              });
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
  }
}
