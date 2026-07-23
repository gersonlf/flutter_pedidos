import 'package:flutter/material.dart';

import 'app/pedidos_app.dart';
import 'core/platform/app_fullscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFullscreenSupport();
  runApp(const PedidosApp());
}
