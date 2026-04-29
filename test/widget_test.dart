import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pedidos_restaurante/app/pedidos_app.dart';

void main() {
  testWidgets('shows app home and settings entry point', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PedidosApp());
    await tester.pumpAndSettle();

    expect(find.text('Pedidos Restaurante'), findsOneWidget);
    expect(find.text('Configure o servidor'), findsOneWidget);
    expect(find.text('Configurar'), findsOneWidget);
  });
}
