// ignore_for_file: avoid_web_libraries_in_flutter

// ignore: deprecated_member_use
import 'dart:html' as html;

Future<void> initializeFullscreenSupportForPlatform() async {}

Future<bool> toggleAppFullscreenForPlatform() async {
  final document = html.document;
  final element = document.documentElement;
  if (element == null) {
    return false;
  }

  try {
    if (document.fullscreenElement != null) {
      document.exitFullscreen();
    } else {
      await element.requestFullscreen();
    }
    return true;
  } catch (_) {
    return false;
  }
}
