import 'package:flutter/material.dart';
import 'package:powersync/powersync.dart' as ps;

import '../data/todo_repository.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key, required this.repository});
  final TodoRepository repository;

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  late final Stream<List<Todo>> _todos = widget.repository.watch();

  @override
  Widget build(BuildContext context) {
    final database = widget.repository.database;
    return Scaffold(
      appBar: AppBar(title: const Text('PowerSync Cloud Sample')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                StreamBuilder<ps.SyncStatus>(
                  stream: database.statusStream,
                  initialData: database.currentStatus,
                  builder: (context, snapshot) {
                    final status = snapshot.data ?? database.currentStatus;
                    final label = status.anyError != null
                        ? '同期エラー・再試行中'
                        : status.connecting
                        ? 'Cloud に接続中…'
                        : !status.connected
                        ? 'オフライン・保存済みデータを表示'
                        : status.downloading
                        ? '受信中…'
                        : status.hasSynced == true
                        ? 'Cloud に接続済み'
                        : '初回同期を待っています…';
                    return ListTile(
                      leading: Icon(
                        status.connected ? Icons.cloud_done : Icons.cloud_off,
                      ),
                      title: Text(label),
                      subtitle: status.anyError != null
                          ? SelectableText('${status.anyError}')
                          : Text(
                              status.lastSyncedAt == null
                                  ? '初回のデータ受信には通信が必要です'
                                  : '最終同期: ${status.lastSyncedAt!.toLocal()}',
                            ),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('受信専用のサンプルです。同期元の todos テーブルを更新すると一覧に反映されます。'),
                ),
                const Divider(),
                Expanded(
                  child: StreamBuilder<List<Todo>>(
                    stream: _todos,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('読み込みエラー: ${snapshot.error}'),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final todos = snapshot.data!;
                      if (todos.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              '表示する ToDo はありません。同期状態と同期元データを確認してください。',
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return ListTile(
                            key: ValueKey(todo.id),
                            leading: Icon(
                              todo.completed
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                            ),
                            title: Text(
                              todo.description,
                              style: TextStyle(
                                decoration: todo.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
