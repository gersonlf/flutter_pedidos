import 'dart:async';
import 'dart:convert';

import 'package:flutter_pedidos/core/config/app_config.dart';
import 'package:flutter_pedidos/core/network/api_client.dart';
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
    settingsPassword: '',
  );

  test('postJson returns null for empty response when allowed', () async {
    final client = ApiClient(
      config: config,
      client: _FakeClient(responseBody: ''),
    );

    final decoded = await client.postJson(
      scriptName: 'alterarComanda',
      body: const <String, Object?>{},
      failureMessage: 'Nao foi possivel alterar comanda',
    );

    expect(decoded, isNull);
  });

  test('postJson extracts JSON list from noisy PHP response', () async {
    final client = ApiClient(
      config: config,
      client: _FakeClient(
        responseBody:
            'Deprecated: utf8_encode() is deprecated on line 54\n'
            '[{"codigo_produto":"10"}]',
      ),
    );

    final decoded = await client.postJson(
      scriptName: 'lerProdutos',
      body: const <String, Object?>{},
      failureMessage: 'Nao foi possivel carregar produtos',
      invalidMessage: 'Resposta invalida ao carregar produtos.',
    );

    expect(decoded, isA<List>());
    expect((decoded as List).single, {'codigo_produto': '10'});
  });

  test('postJson includes response preview for invalid response', () {
    final client = ApiClient(
      config: config,
      client: _FakeClient(responseBody: '<br />PHP Fatal error'),
    );

    expect(
      client.postJson(
        scriptName: 'lerProdutos',
        body: const <String, Object?>{},
        failureMessage: 'Nao foi possivel carregar produtos',
        invalidMessage: 'Resposta invalida ao carregar produtos.',
      ),
      throwsA(
        isA<ApiClientException>().having(
          (error) => error.message,
          'message',
          contains('Trecho recebido: <br />PHP Fatal error'),
        ),
      ),
    );
  });

  test('postJson throws server message from standardized error payload', () {
    final client = ApiClient(
      config: config,
      client: _FakeClient(
        responseBody: '{"sucesso":false,"mensagem":"Erro consultando dados"}',
        statusCode: 500,
      ),
    );

    expect(
      client.postJson(
        scriptName: 'lerProdutos',
        body: const <String, Object?>{},
        failureMessage: 'Nao foi possivel carregar produtos',
      ),
      throwsA(
        isA<ApiClientException>().having(
          (error) => error.message,
          'message',
          'Erro consultando dados',
        ),
      ),
    );
  });
}

class _FakeClient extends http.BaseClient {
  _FakeClient({required this.responseBody, this.statusCode = 200});

  final String responseBody;
  final int statusCode;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value(utf8.encode(responseBody)),
      statusCode,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }
}
