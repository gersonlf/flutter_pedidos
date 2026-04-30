import 'dart:async';
import 'dart:convert';

import 'package:flutter_pedidos/core/config/app_config.dart';
import 'package:flutter_pedidos/core/models/funcionario.dart';
import 'package:flutter_pedidos/core/models/produto.dart';
import 'package:flutter_pedidos/features/commands/command_selection.dart';
import 'package:flutter_pedidos/features/items/item_repository.dart';
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
  const product = Produto(
    codigo: 10,
    codigoReduzido: 5,
    codigoBarra: '789',
    descricao: 'COCA COLA',
    grupo: 1,
    valorUnitario: 5.5,
    unidade: 'UN',
  );

  test('addItem sends empty codigo_tag when command has no real tag', () async {
    final client = _RecordingClient();
    final repository = ItemRepository(config: config, client: client);

    await repository.addItem(
      employee: employee,
      command: const CommandSelection(
        codigoComanda: 1,
        codigoMesa: 0,
        codigoTag: 0,
        bloqueio: 0,
      ),
      product: product,
      quantity: 1,
    );

    expect(client.lastBody['codigo_tag'], '');
  });

  test('addItem sends codigo_tag when command has a real tag', () async {
    final client = _RecordingClient();
    final repository = ItemRepository(config: config, client: client);

    await repository.addItem(
      employee: employee,
      command: const CommandSelection(
        codigoComanda: 1,
        codigoMesa: 0,
        codigoTag: 123,
        bloqueio: 0,
      ),
      product: product,
      quantity: 1,
    );

    expect(client.lastBody['codigo_tag'], '123');
  });
}

class _RecordingClient extends http.BaseClient {
  Map<String, dynamic> lastBody = const {};

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is http.Request) {
      lastBody = jsonDecode(request.body) as Map<String, dynamic>;
    }

    return http.StreamedResponse(
      Stream.value(utf8.encode('[{"codigoVenda":"1","itemVenda":"1"}]')),
      200,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }
}
