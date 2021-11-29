import 'package:hive/hive.dart';

class Todo extends HiveObject {
  Todo(this.text, {this.done = false});
  bool done = false;
  String text;

  void toggleDone() {
    done = !done;
  }

  void setText(String text) {
    this.text = text;
  }
}

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  Todo read(BinaryReader reader) {
    String text = reader.readString();
    bool done = reader.readBool();

    return Todo(text, done: done);
  }

  @override
  final typeId = 0;

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.writeString(obj.text);
    writer.writeBool(obj.done);
  }
}