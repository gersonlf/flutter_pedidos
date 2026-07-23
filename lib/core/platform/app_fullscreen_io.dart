import 'dart:io';

import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initializeFullscreenSupportForPlatform() async {
  if (_isDesktop) {
    await windowManager.ensureInitialized();
  }
}

Future<bool> toggleAppFullscreenForPlatform() async {
  if (_isDesktop) {
    final fullScreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!fullScreen);
    return true;
  }

  if (Platform.isAndroid || Platform.isIOS) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return true;
  }

  return false;
}

bool get _isDesktop {
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}
