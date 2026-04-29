import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/models/funcionario.dart';
import '../../core/models/pedido_cozinha.dart';

class KitchenRepository {
  const KitchenRepository({required this.config, http.Client? client})
    : _client = client;

  final AppConfig config;
  final http.Client? _client;

  Future<List<PedidoCozinha>> fetchOrders(PedidoCozinhaTipo tipo) async {
    final decoded = await _postJson(
      scriptName: 'lerPedidos',
      body: {'tipo_pedido': tipo.payload},
      failureMessage: 'Nao foi possivel carregar pedidos',
    );

    if (decoded is! List) {
      throw const KitchenRepositoryException(
        'Resposta invalida ao carregar pedidos.',
      );
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(PedidoCozinha.fromJson)
        .where((pedido) => pedido.codigoComanda > 0)
        .toList();
  }

  Future<void> callReadyOrder({
    required Funcionario employee,
    required int codigoComanda,
  }) async {
    await _postJson(
      scriptName: 'lerPedidoPronto',
      body: {
        'codigo_comanda': codigoComanda.toString(),
        'nome_funcionario': employee.nome,
      },
      failureMessage: 'Nao foi possivel chamar pedido',
    );
  }

  Future<void> removeDeliveredOrder({
    required Funcionario employee,
    required int codigoComanda,
  }) async {
    await _postJson(
      scriptName: 'lerPedidoEntregue',
      body: {
        'codigo_comanda': codigoComanda.toString(),
        'nome_funcionario': employee.nome,
      },
      failureMessage: 'Nao foi possivel remover pedido',
    );
  }

  Future<void> sendCommandToKitchen({
    required Funcionario employee,
    required int codigoComanda,
  }) async {
    await _postJson(
      scriptName: 'imprimirComanda',
      body: {
        'codigo_comanda': codigoComanda.toString(),
        'nome_funcionario': employee.nome,
      },
      failureMessage: 'Nao foi possivel enviar comanda para cozinha',
    );
  }

  Future<Object?> _postJson({
    required String scriptName,
    required Map<String, String> body,
    required String failureMessage,
  }) async {
    final client = _client ?? http.Client();

    try {
      final response = await client
          .post(
            config.endpoint(scriptName),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=utf-8',
              'Connection': 'Close',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw KitchenRepositoryException(
          '$failureMessage (${response.statusCode}).',
        );
      }

      if (response.body.trim().isEmpty) {
        return null;
      }

      return jsonDecode(response.body);
    } on KitchenRepositoryException {
      rethrow;
    } on FormatException catch (error) {
      throw KitchenRepositoryException(
        'Resposta invalida do servidor: ${error.message}',
      );
    } catch (error) {
      throw KitchenRepositoryException('$failureMessage: $error');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}

class KitchenRepositoryException implements Exception {
  const KitchenRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
