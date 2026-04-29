import 'package:flutter/material.dart';

import '../core/config/app_config_store.dart';
import '../features/home/home_page.dart';

class PedidosApp extends StatelessWidget {
  const PedidosApp({super.key, AppConfigStore? configStore})
    : _configStore = configStore;

  final AppConfigStore? _configStore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF006D77),
    );

    return MaterialApp(
      title: 'Pedidos Restaurante',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: colorScheme.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: HomePage(configStore: _configStore ?? AppConfigStore()),
    );
  }
}
