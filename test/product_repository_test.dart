import 'dart:async';
import 'dart:convert';

import 'package:flutter_pedidos/core/config/app_config.dart';
import 'package:flutter_pedidos/features/products/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  const config = AppConfig(
    server: 'localhost',
    port: 80,
    context: 'pedido.teste',
    protocol: AppProtocol.http,
    physicalKeyboardEnabled: false,
    commandCheckDigitEnabled: false,
    requirePasswordToDelete: false,
  );

  test('searchProducts tolerates PHP warnings around JSON list', () async {
    final client = _FakeClient(
      responseBody:
          'Deprecated: utf8_encode() is deprecated in lerProdutos.php on line 54\n'
          '[{"codigo_produto":"10","codigo_reduzido":"5","codigo_barra":"789",'
          '"descricao_produto":"COCA COLA","grupo_produto":"1",'
          '"valor_unitario":"5.50","unidade_produto":"UN"}]',
    );
    final repository = ProductRepository(config: config, client: client);

    final products = await repository.searchProducts('coca');

    expect(products, hasLength(1));
    expect(products.single.codigo, 10);
    expect(products.single.descricao, 'COCA COLA');
    expect(products.single.valorUnitario, 5.5);
  });

  test('searchProducts includes a response preview when JSON is invalid', () {
    final client = _FakeClient(
      responseBody: '<br />PHP Fatal error: database unavailable',
    );
    final repository = ProductRepository(config: config, client: client);

    expect(
      repository.searchProducts('coca'),
      throwsA(
        isA<ProductRepositoryException>().having(
          (error) => error.message,
          'message',
          contains('Trecho recebido: <br />PHP Fatal error'),
        ),
      ),
    );
  });
}

class _FakeClient extends http.BaseClient {
  _FakeClient({required this.responseBody});

  final String responseBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final bytes = utf8.encode(responseBody);
    return http.StreamedResponse(
      Stream.value(bytes),
      200,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }
}
