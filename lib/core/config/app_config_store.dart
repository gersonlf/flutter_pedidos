import 'package:shared_preferences/shared_preferences.dart';

import 'app_config.dart';

class AppConfigStore {
  static const _serverKey = 'config.server';
  static const _portKey = 'config.port';
  static const _contextKey = 'config.context';
  static const _protocolKey = 'config.protocol';
  static const _physicalKeyboardKey = 'config.physical_keyboard';
  static const _commandCheckDigitKey = 'config.command_check_digit';
  static const _requirePasswordToDeleteKey =
      'config.require_password_to_delete';

  Future<AppConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = AppConfig.defaults();

    return AppConfig(
      server: prefs.getString(_serverKey) ?? defaults.server,
      port: prefs.getInt(_portKey) ?? defaults.port,
      context: prefs.getString(_contextKey) ?? defaults.context,
      protocol: AppProtocol.fromValue(
        prefs.getString(_protocolKey) ?? defaults.protocol.value,
      ),
      physicalKeyboardEnabled:
          prefs.getBool(_physicalKeyboardKey) ??
          defaults.physicalKeyboardEnabled,
      commandCheckDigitEnabled:
          prefs.getBool(_commandCheckDigitKey) ??
          defaults.commandCheckDigitEnabled,
      requirePasswordToDelete:
          prefs.getBool(_requirePasswordToDeleteKey) ??
          defaults.requirePasswordToDelete,
    );
  }

  Future<void> save(AppConfig config) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_serverKey, config.server);
    await prefs.setInt(_portKey, config.port);
    await prefs.setString(_contextKey, config.context);
    await prefs.setString(_protocolKey, config.protocol.value);
    await prefs.setBool(_physicalKeyboardKey, config.physicalKeyboardEnabled);
    await prefs.setBool(_commandCheckDigitKey, config.commandCheckDigitEnabled);
    await prefs.setBool(
      _requirePasswordToDeleteKey,
      config.requirePasswordToDelete,
    );
  }
}
