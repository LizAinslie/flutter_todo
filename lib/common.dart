import 'package:hive/hive.dart';

import 'todo.dart';

const settingsBox = 'settings';

List<Todo> makeDefaultTodos() => [
  Todo('This is a todo list app'),
  Todo('Use the button below to add things'),
  Todo('Tap an item to mark it done'),
  Todo('Tap it again to mark it undone'),
  Todo('Finally, tap and hold an item to remove it')
];

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