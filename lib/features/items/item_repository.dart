import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/models/funcionario.dart';
import '../../core/models/item_comanda.dart';
import '../../core/models/produto.dart';
import '../commands/command_selection.dart';

class ItemRepository {
  const ItemRepository({required this.config, http.Client? client})
    : _client = client;

  final AppConfig config;
  final http.Client? _client;

  Future<List<ItemComanda>> fetchItems(int codigoComanda) async {
    final client = _client ?? http.Client();

    try {
      final response = await client
          .post(
            config.endpoint('lerItens'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=utf-8',
              'Connection': 'Close',
            },
            body: jsonEncode({'codigo_comanda': codigoComanda.toString()}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw ItemRepositoryException(
          'Erro carregando itens (${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const ItemRepositoryException(
          'Resposta invalida ao carregar itens.',
        );
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ItemComanda.fromJson)
          .where(
            (item) => item.itemVenda > 0 && item.descricaoProduto.isNotEmpty,
          )
          .toList();
    } on ItemRepositoryException {
      rethrow;
    } on FormatException catch (error) {
      throw ItemRepositoryException(
        'Resposta invalida ao carregar itens: ${error.message}',
      );
    } catch (error) {
      throw ItemRepositoryException('Nao foi possivel carregar itens: $error');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  Future<void> addItem({
    required Funcionario employee,
    required CommandSelection command,
    required Produto product,
    required double quantity,
    String observation = '',
  }) async {
    final client = _client ?? http.Client();
    final total = quantity * product.valorUnitario;

    try {
      final response = await client
          .post(
            config.endpoint('incluirItem'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=utf-8',
              'Connection': 'Close',
            },
            body: jsonEncode({
              'codigo_comanda': command.codigoComanda.toString(),
              'codigo_mesa': command.codigoMesa.toString(),
              'codigo_tag': command.codigoTag.toString(),
              'codigo_funcionario': employee.codigo.toString(),
              'nome_funcionario': employee.nome,
              'codigo_produto': product.codigo.toString(),
              'codigo_barra': product.codigoBarra,
              'codigo_reduzido': product.codigoReduzido.toString(),
              'descricao_produto': product.descricao,
              'qtde_produto': quantity.toStringAsFixed(3),
              'valor_unitario': product.valorUnitario,
              'valor_total': total,
              'observacao_item': observation,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw ItemRepositoryException(
          'Erro incluindo item (${response.statusCode}).',
        );
      }
    } catch (error) {
      if (error is ItemRepositoryException) {
        rethrow;
      }
      throw ItemRepositoryException('Nao foi possivel incluir item: $error');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  Future<void> updateObservation({
    required Funcionario employee,
    required CommandSelection command,
    required ItemComanda item,
    required String observation,
  }) async {
    final decoded = await _postJson(
      scriptName: 'alterarObservacao',
      body: {
        'codigo_comanda': command.codigoComanda.toString(),
        'item_venda': item.itemVenda.toString(),
        'nome_funcionario': employee.nome,
        'observacao_item': observation,
      },
      failureMessage: 'Nao foi possivel alterar observacao',
    );

    if (decoded is Map<String, dynamic>) {
      final message = (decoded['msg'] ?? '').toString().trim();
      if (message.isNotEmpty) {
        throw ItemRepositoryException(message);
      }
    }
  }

  Future<void> deleteItem({
    required Funcionario employee,
    required CommandSelection command,
    required ItemComanda item,
  }) async {
    await _postJson(
      scriptName: 'excluirComanda',
      body: {
        'codigo_comanda': command.codigoComanda.toString(),
        'item_venda': item.itemVenda.toString(),
        'codigo_funcionario': employee.codigo.toString(),
        'nome_funcionario': employee.nome,
      },
      failureMessage: 'Nao foi possivel excluir item',
    );
  }

  Future<Object?> _postJson({
    required String scriptName,
    required Map<String, Object> body,
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
        throw ItemRepositoryException(
          '$failureMessage (${response.statusCode}).',
        );
      }

      if (response.body.trim().isEmpty) {
        return null;
      }

      return jsonDecode(response.body);
    } on ItemRepositoryException {
      rethrow;
    } on FormatException catch (error) {
      throw ItemRepositoryException(
        'Resposta invalida do servidor: ${error.message}',
      );
    } catch (error) {
      throw ItemRepositoryException('$failureMessage: $error');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}

class ItemRepositoryException implements Exception {
  const ItemRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
