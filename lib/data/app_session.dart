import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

import '../app_config.dart';
import 'cloud_connector.dart';
import 'schema.dart';
import 'todo_repository.dart';

class AppSession {
  AppSession._(this.database) : todos = TodoRepository(database);

  final PowerSyncDatabase database;
  final TodoRepository todos;

  static Future<AppSession> open(AppConfig config) async {
    final directory = await getApplicationSupportDirectory();
    // Keep cached data separate for each Cloud instance and token subject.
    final cacheId = const Uuid().v5(
      Namespace.url.value,
      '${config.powerSyncUrl}|${config.userId}',
    );
    final database = PowerSyncDatabase(
      schema: appSchema,
      path: p.join(directory.path, 'cloud-todos-$cacheId.db'),
    );
    try {
      await database.initialize();
      await database.connect(connector: CloudConnector(config));
      return AppSession._(database);
    } catch (_) {
      await database.close();
      rethrow;
    }
  }

  Future<void> close() async {
    await database.disconnect();
    await database.close();
  }
}
