import 'dart:async';

import 'package:flutter/material.dart';

import 'app_config.dart';
import 'data/app_session.dart';
import 'ui/todos_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.config = const AppConfig()});
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PowerSync Cloud Sample',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: config.isConfigured ? CloudPage(config: config) : const SetupPage(),
    );
  }
}

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PowerSync Cloud Sample')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.cloud_sync, size: 48),
                SizedBox(height: 16),
                Text('PowerSync Cloud の接続設定', style: TextStyle(fontSize: 24)),
                SizedBox(height: 16),
                Text(
                  '.env に Cloud のインスタンス URL と開発用トークンを入力してください。ファイルがない場合は .env.example をコピーしてください。',
                ),
                SizedBox(height: 16),
                SelectableText(
                  'flutter run --dart-define-from-file=.env',
                ),
                SizedBox(height: 16),
                Text(
                  'このサンプルは Cloud から ToDo を受信し、オフラインでも表示します。同期元データベースの準備と Sync Streams の設定手順は README.md を参照してください。',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CloudPage extends StatefulWidget {
  const CloudPage({super.key, required this.config});
  final AppConfig config;

  @override
  State<CloudPage> createState() => _CloudPageState();
}

class _CloudPageState extends State<CloudPage> {
  late Future<AppSession> _session = AppSession.open(widget.config);
  AppSession? _opened;

  @override
  void dispose() {
    unawaited(
      _session.then((session) => session.close()).catchError((Object _) {}),
    );
    super.dispose();
  }

  void _retry() {
    setState(() => _session = AppSession.open(widget.config));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppSession>(
      future: _session,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('初期化エラー')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SelectableText('${snapshot.error}'),
                  FilledButton(onPressed: _retry, child: const Text('再試行')),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        _opened = snapshot.data;
        return TodosPage(repository: _opened!.todos);
      },
    );
  }
}
