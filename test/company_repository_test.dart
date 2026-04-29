import 'dart:async';
import 'dart:convert';

import 'package:flutter_pedidos/core/config/app_config.dart';
import 'package:flutter_pedidos/core/models/empresa_config.dart';
import 'package:flutter_pedidos/features/company/company_repository.dart';
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

  test('fetchCompanyConfig parses company flags from lerEmpresas', () async {
    final repository = CompanyRepository(
      config: config,
      client: _FakeClient(
        responseBody:
            '[{"controla_mesa":"S","controla_tag":"N",'
            '"controla_troca":"D","controla_cozinha":"S"}]',
      ),
    );

    final companyConfig = await repository.fetchCompanyConfig();

    expect(companyConfig.controlaMesa, isTrue);
    expect(companyConfig.controlaTag, isFalse);
    expect(companyConfig.controlaTroca, TrocaComandaPolicy.desabilitada);
    expect(companyConfig.controlaCozinha, isTrue);
  });

  test('fetchCompanyConfig maps troca S to password policy', () async {
    final repository = CompanyRepository(
      config: config,
      client: _FakeClient(
        responseBody:
            '[{"controla_mesa":"N","controla_tag":"S",'
            '"controla_troca":"S","controla_cozinha":"N"}]',
      ),
    );

    final companyConfig = await repository.fetchCompanyConfig();

    expect(companyConfig.controlaMesa, isFalse);
    expect(companyConfig.controlaTag, isTrue);
    expect(companyConfig.controlaTroca, TrocaComandaPolicy.exigeSenha);
    expect(companyConfig.controlaCozinha, isFalse);
  });

  test('fetchCompanyConfig rejects invalid payloads', () {
    final repository = CompanyRepository(
      config: config,
      client: _FakeClient(responseBody: '{}'),
    );

    expect(
      repository.fetchCompanyConfig(),
      throwsA(isA<CompanyRepositoryException>()),
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
