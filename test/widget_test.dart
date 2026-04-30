import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pedidos/app/pedidos_app.dart';

void main() {
  testWidgets('shows app home and settings entry point', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PedidosApp());
    await tester.pumpAndSettle();

    expect(find.text('Pedidos Restaurante'), findsOneWidget);
    expect(find.text('Configure o servidor'), findsOneWidget);
    expect(find.text('Configurar'), findsWidgets);
  });

  testWidgets('asks local password before opening settings', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'config.settings_password': '1234',
    });

    await tester.pumpWidget(const PedidosApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Configurar').first);
    await tester.pumpAndSettle();

    expect(find.text('Senha da configuracao'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
