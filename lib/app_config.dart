import 'dart:convert';

// Flutter injects .env values at build time with --dart-define-from-file=.env.
// Only development credentials belong here; values are included in the app.
class AppConfig {
  const AppConfig({
    this.powerSyncUrl = const String.fromEnvironment('POWERSYNC_URL'),
    this.developmentToken = const String.fromEnvironment('POWERSYNC_DEV_TOKEN'),
  });

  final String powerSyncUrl;
  final String developmentToken;

  Map<String, dynamic>? get _claims {
    try {
      final parts = developmentToken.split('.');
      if (parts.length != 3) return null;
      return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Claims are used only for cache separation and expiry hints.
  // Authentication and signature verification are performed by PowerSync Cloud.
  String? get userId =>
      _claims?['sub'] is String ? _claims!['sub'] as String : null;

  DateTime? get expiresAt {
    final exp = _claims?['exp'];
    return exp is num
        ? DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000)
        : null;
  }

  bool get isConfigured {
    final uri = Uri.tryParse(powerSyncUrl);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        userId != null &&
        userId!.isNotEmpty;
  }
}
