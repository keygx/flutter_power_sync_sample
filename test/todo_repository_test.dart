import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:powersync/powersync.dart';
import 'package:flutter_power_sync_sample/app_config.dart';
import 'package:flutter_power_sync_sample/data/cloud_connector.dart';
import 'package:flutter_power_sync_sample/data/schema.dart';
import 'package:flutter_power_sync_sample/data/todo_repository.dart';

void main() {
  test('Cached todos remain readable after reopening offline', () async {
    final directory = await Directory.systemTemp.createTemp('powersync-test-');
    final path = p.join(directory.path, 'cache.db');
    var db = PowerSyncDatabase(schema: appSchema, path: path);
    try {
      await db.initialize();
      // Seed through SQL for this test only; the app exposes no write actions.
      await db.execute(
        'INSERT INTO todos (id, description, completed, created_at) VALUES (?, ?, ?, ?)',
        ['todo-1', 'Cached task', 1, '2026-11-02T00:00:00Z'],
      );
      var todos = await TodoRepository(db).watch().first;
      expect(todos.single.description, 'Cached task');
      expect(todos.single.completed, isTrue);
      await db.close();
      db = PowerSyncDatabase(schema: appSchema, path: path);
      await db.initialize();
      todos = await TodoRepository(db).watch().first;
      expect(todos.single.id, 'todo-1');
      // An accidental local write must never be silently discarded.
      await expectLater(
        CloudConnector(const AppConfig()).uploadData(db),
        throwsUnsupportedError,
      );
      expect(await db.getNextCrudTransaction(), isNotNull);
    } finally {
      await db.close();
      await directory.delete(recursive: true);
    }
  });
}
