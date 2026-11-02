import 'package:powersync/powersync.dart';

const appSchema = Schema([
  Table('todos', [
    Column.text('owner_id'),
    Column.text('description'),
    Column.integer('completed'),
    Column.text('created_at'),
  ]),
]);
