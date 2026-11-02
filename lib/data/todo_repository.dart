import 'package:powersync/powersync.dart';

class Todo {
  const Todo({required this.id, required this.description, required this.completed});
  final String id;
  final String description;
  final bool completed;
}

class TodoRepository {
  TodoRepository(this.database);
  final PowerSyncDatabase database;

  Stream<List<Todo>> watch() => database.watch(
    'SELECT id, description, completed FROM todos ORDER BY created_at DESC, id',
  ).map((rows) => [
    for (final row in rows)
      Todo(
        id: row['id'] as String,
        description: row['description'] as String? ?? '',
        completed: row['completed'] == 1,
      ),
  ]);
}
