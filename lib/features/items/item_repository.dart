import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/models/funcionario.dart';
import '../../core/models/item_comanda.dart';
import '../../core/models/produto.dart';
import '../../core/network/api_client.dart';
import '../commands/command_repository.dart';
import '../commands/command_selection.dart';

class ItemRepository {
  const ItemRepository({required this.config, http.Client? client})
    : _client = client;

  final AppConfig config;
  final http.Client? _client;

  Future<List<ItemComanda>> fetchItems(int codigoComanda) async {
    try {
      final decoded = await ApiClient(config: config, client: _client).postJson(
        scriptName: 'lerItens',
        body: {'codigo_comanda': codigoComanda.toString()},
        failureMessage: 'Nao foi possivel carregar itens',
        invalidMessage: 'Resposta invalida ao carregar itens.',
        allowEmptyResponse: false,
      );

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
    } on ApiClientException catch (error) {
      throw ItemRepositoryException(error.message);
    } catch (error) {
      throw ItemRepositoryException('Nao foi possivel carregar itens: $error');
    }
  }

  Future<void> addItem({
    required Funcionario employee,
    required CommandSelection command,
    required Produto product,
    required double quantity,
    String observation = '',
  }) async {
    final total = quantity * product.valorUnitario;

    try {
      await ApiClient(config: config, client: _client).postJson(
        scriptName: 'incluirItem',
        body: {
          'codigo_comanda': command.codigoComanda.toString(),
          'codigo_mesa': command.codigoMesa.toString(),
          'codigo_tag': command.codigoTag > 0
              ? command.codigoTag.toString()
              : '',
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
        },
        failureMessage: 'Nao foi possivel incluir item',
        invalidMessage: 'Resposta invalida ao incluir item.',
      );
    } catch (error) {
      if (error is ItemRepositoryException) {
        rethrow;
      }
      if (error is ApiClientException) {
        throw ItemRepositoryException(error.message);
      }
      throw ItemRepositoryException('Nao foi possivel incluir item: $error');
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

  Future<void> changeItemCommand({
    required Funcionario employee,
    required CommandSelection command,
    required ItemComanda item,
    required int novaComanda,
  }) async {
    final commandRepository = CommandRepository(
      config: config,
      client: _client,
    );
    await commandRepository.changeCommand(
      employee: employee,
      codigoComanda: command.codigoComanda,
      novaComanda: novaComanda,
      itemVenda: item.itemVenda,
    );
  }

  Future<Object?> _postJson({
    required String scriptName,
    required Map<String, Object> body,
    required String failureMessage,
  }) async {
    try {
      return await ApiClient(config: config, client: _client).postJson(
        scriptName: scriptName,
        body: body,
        failureMessage: failureMessage,
        invalidMessage: 'Resposta invalida do servidor.',
      );
    } on ItemRepositoryException {
      rethrow;
    } on ApiClientException catch (error) {
      throw ItemRepositoryException(error.message);
    } catch (error) {
      throw ItemRepositoryException('$failureMessage: $error');
    }
  }
}

class ItemRepositoryException implements Exception {
  const ItemRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
