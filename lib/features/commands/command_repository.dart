import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/models/comanda.dart';
import '../../core/models/funcionario.dart';
import '../../core/network/api_client.dart';
import 'command_selection.dart';

class CommandRepository {
  const CommandRepository({required this.config, http.Client? client})
    : _client = client;

  final AppConfig config;
  final http.Client? _client;

  Future<List<Comanda>> fetchCommands({int? codigoComanda}) async {
    final decoded = await _postJson(
      scriptName: 'lerComandas',
      body: {'codigo_comanda': codigoComanda?.toString() ?? ''},
    );

    if (decoded is! List) {
      throw const CommandRepositoryException(
        'Resposta invalida ao carregar comandas.',
      );
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Comanda.fromJson)
        .where((command) => command.codigoComanda > 0)
        .toList();
  }

  Future<CommandSelection> lookupCommand(int codigoComanda) async {
    final results = await fetchCommands(codigoComanda: codigoComanda);
    final mesa = await fetchMesa(codigoComanda);
    final tag = await fetchTag(codigoComanda);
    final bloqueio = await fetchBloqueio(codigoComanda);

    return CommandSelection(
      codigoComanda: codigoComanda,
      codigoMesa: mesa,
      codigoTag: tag,
      bloqueio: bloqueio,
      comanda: results.isEmpty ? null : results.first,
    );
  }

  Future<int> fetchMesa(int codigoComanda) async {
    final decoded = await _postJson(
      scriptName: 'lerMesa',
      body: {'codigo_comanda': codigoComanda.toString()},
    );

    if (decoded is! Map<String, dynamic>) {
      throw const CommandRepositoryException(
        'Resposta invalida ao consultar mesa.',
      );
    }

    return _parseInt(decoded['mesa']);
  }

  Future<int> fetchTag(int codigoComanda) async {
    final decoded = await _postJson(
      scriptName: 'lerTag',
      body: {'codigo_comanda': codigoComanda.toString()},
    );

    if (decoded is! Map<String, dynamic>) {
      throw const CommandRepositoryException(
        'Resposta invalida ao consultar tag.',
      );
    }

    return _parseInt(decoded['tag']);
  }

  Future<int> fetchBloqueio(int codigoComanda) async {
    final decoded = await _postJson(
      scriptName: 'lerBloqueio',
      body: {'codigo_comanda': codigoComanda.toString()},
    );

    if (decoded is! Map<String, dynamic>) {
      throw const CommandRepositoryException(
        'Resposta invalida ao consultar bloqueio.',
      );
    }

    return _parseInt(decoded['bloqueio']);
  }

  Future<void> updateMesa({
    required Funcionario employee,
    required int codigoComanda,
    required int novaMesa,
  }) async {
    await _postJson(
      scriptName: 'alterarMesa',
      body: {
        'codigo_comanda': codigoComanda.toString(),
        'codigo_nova_mesa': novaMesa.toString(),
        'nome_funcionario': employee.nome,
      },
    );
  }

  Future<void> deleteCommand({
    required Funcionario employee,
    required int codigoComanda,
  }) async {
    await _postJson(
      scriptName: 'excluirComanda',
      body: {
        'codigo_comanda': codigoComanda.toString(),
        'codigo_funcionario': employee.codigo.toString(),
        'nome_funcionario': employee.nome,
        'item_venda': '0',
      },
    );
  }

  Future<void> changeCommand({
    required Funcionario employee,
    required int codigoComanda,
    required int novaComanda,
    int itemVenda = 0,
  }) async {
    await _postJson(
      scriptName: 'alterarComanda',
      body: {
        'codigo_comanda': codigoComanda.toString(),
        'codigo_nova_comanda': novaComanda.toString(),
        'codigo_funcionario': employee.codigo.toString(),
        'nome_funcionario': employee.nome,
        'item_venda': itemVenda.toString(),
      },
    );
  }

  Future<Object?> _postJson({
    required String scriptName,
    required Map<String, String> body,
  }) async {
    try {
      return await ApiClient(config: config, client: _client).postJson(
        scriptName: scriptName,
        body: body,
        failureMessage: 'Nao foi possivel acessar $scriptName',
        invalidMessage: 'Resposta invalida do servidor.',
      );
    } on CommandRepositoryException {
      rethrow;
    } on ApiClientException catch (error) {
      throw CommandRepositoryException(error.message);
    } catch (error) {
      throw CommandRepositoryException(
        'Nao foi possivel acessar o servidor: $error',
      );
    }
  }

  static int _parseInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class CommandRepositoryException implements Exception {
  const CommandRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
