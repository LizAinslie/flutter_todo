import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../todo.dart';
import '../components/todo_item.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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