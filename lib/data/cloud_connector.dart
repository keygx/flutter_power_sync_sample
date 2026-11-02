import 'package:powersync/powersync.dart';

import '../app_config.dart';

/// Development-only authentication for PowerSync Cloud.
/// Replace the fixed token with your backend's token endpoint for production.
class CloudConnector extends PowerSyncBackendConnector {
  CloudConnector(this.config);
  final AppConfig config;

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final expiresAt = config.expiresAt;
    if (expiresAt != null && !expiresAt.isAfter(DateTime.now())) {
      throw StateError('開発用トークンの有効期限が切れています。Cloud で再発行してアプリを再起動してください。');
    }
    return PowerSyncCredentials(
      endpoint: config.powerSyncUrl,
      token: config.developmentToken,
      userId: config.userId,
      expiresAt: expiresAt,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    // This sample only receives changes. Cloud does not provide a CRUD API
    // for writing to your source database. Never silently acknowledge writes.
    throw UnsupportedError('このサンプルは受信専用です。書き込みにはバックエンド API の実装が必要です。');
  }
}
