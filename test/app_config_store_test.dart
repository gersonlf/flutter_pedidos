import 'package:flutter_pedidos/core/config/app_config.dart';
import 'package:flutter_pedidos/core/config/app_config_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('save and load preserves settings password', () async {
    SharedPreferences.setMockInitialValues({});
    final store = AppConfigStore();

    await store.save(
      const AppConfig(
        server: '192.168.0.10',
        port: 8080,
        context: 'pedido.teste',
        protocol: AppProtocol.http,
        physicalKeyboardEnabled: true,
        commandCheckDigitEnabled: true,
        requirePasswordToDelete: true,
        settingsPassword: '1234',
      ),
    );

    final config = await store.load();

    expect(config.settingsPassword, '1234');
    expect(config.hasSettingsPassword, isTrue);
  });

  test('default settings password leaves settings unlocked', () async {
    SharedPreferences.setMockInitialValues({});
    final config = await AppConfigStore().load();

    expect(config.settingsPassword, isEmpty);
    expect(config.hasSettingsPassword, isFalse);
  });
}
