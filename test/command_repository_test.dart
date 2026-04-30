import 'dart:async';
import 'dart:convert';

import 'package:flutter_pedidos/core/config/app_config.dart';
import 'package:flutter_pedidos/core/models/funcionario.dart';
import 'package:flutter_pedidos/features/commands/command_repository.dart';
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

  const employee = Funcionario(codigo: 7, nome: 'ADRIANA');

  test('changeCommand sends item_venda 0 for full command transfer', () async {
    final client = _RecordingClient(responseBody: '');
    final repository = CommandRepository(config: config, client: client);

    await repository.changeCommand(
      employee: employee,
      codigoComanda: 10,
      novaComanda: 20,
    );

    expect(client.lastUrl.path, '/php-pedido.teste/alterarComanda.php');
    expect(client.lastBody['codigo_comanda'], '10');
    expect(client.lastBody['codigo_nova_comanda'], '20');
    expect(client.lastBody['codigo_funcionario'], '7');
    expect(client.lastBody['nome_funcionario'], 'ADRIANA');
    expect(client.lastBody['item_venda'], '0');
  });

  test('changeCommand sends item_venda for single item transfer', () async {
    final client = _RecordingClient(responseBody: '');
    final repository = CommandRepository(config: config, client: client);

    await repository.changeCommand(
      employee: employee,
      codigoComanda: 10,
      novaComanda: 20,
      itemVenda: 3,
    );

    expect(client.lastBody['item_venda'], '3');
  });
}

class _RecordingClient extends http.BaseClient {
  _RecordingClient({this.responseBody = '[]'});

  final String responseBody;
  Uri lastUrl = Uri();
  Map<String, dynamic> lastBody = const {};

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastUrl = request.url;

    if (request is http.Request) {
      lastBody = jsonDecode(request.body) as Map<String, dynamic>;
    }

    return http.StreamedResponse(
      Stream.value(utf8.encode(responseBody)),
      200,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }
}
