import 'package:flutter/material.dart';

import '../todo.dart';

class TodoItem extends StatefulWidget {
  const TodoItem({Key? key, required this.task}) : super(key: key);
  final Todo task;

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.task.text),
      trailing: Icon(
        widget.task.done ? Icons.check_box : Icons.check_box_outline_blank,
        color: widget.task.done ? Colors.green : null,
        semanticLabel: widget.task.done ? 'Mark Not Done' : 'Mark Done',
      ),
      onTap: () {
        widget.task.toggleDone();
        widget.task.save();
      },
      onLongPress: () {
        widget.task.delete();
      },
    );
  }
}
