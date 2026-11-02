import 'dart:convert';

import 'package:flutter_power_sync_sample/app_config.dart';
import 'package:flutter_power_sync_sample/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shows Cloud setup instructions without configuration', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MyApp(
        config: AppConfig(powerSyncUrl: '', developmentToken: ''),
      ),
    );
    expect(find.text('PowerSync Cloud の接続設定'), findsOneWidget);
    expect(
      find.text('flutter run --dart-define-from-file=.env'),
      findsOneWidget,
    );
  });

  test('Configuration requires an HTTPS endpoint and a JWT subject', () {
    final payload = base64Url.encode(
      utf8.encode(jsonEncode({'sub': 'sample-user', 'exp': 2000000000})),
    );
    final config = AppConfig(
      powerSyncUrl: 'https://example.powersync.journeyapps.com',
      developmentToken: 'header.$payload.signature',
    );
    expect(config.isConfigured, isTrue);
    expect(config.userId, 'sample-user');
    expect(
      config.expiresAt,
      DateTime.fromMillisecondsSinceEpoch(2000000000000),
    );
    expect(
      const AppConfig(powerSyncUrl: '', developmentToken: '').isConfigured,
      isFalse,
    );
    expect(
      const AppConfig(
        powerSyncUrl: 'https://example.com',
        developmentToken: 'invalid',
      ).isConfigured,
      isFalse,
    );
  });
}
