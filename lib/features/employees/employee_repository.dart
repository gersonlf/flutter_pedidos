import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/models/funcionario.dart';

class EmployeeRepository {
  const EmployeeRepository({required this.config, http.Client? client})
    : _client = client;

  final AppConfig config;
  final http.Client? _client;

  Future<List<Funcionario>> fetchEmployees() async {
    final client = _client ?? http.Client();

    try {
      final response = await client
          .post(
            config.endpoint('lerFuncionarios'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=utf-8',
              'Connection': 'Close',
            },
            body: '{}',
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw EmployeeRepositoryException(
          'Erro carregando funcionarios (${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const EmployeeRepositoryException(
          'Resposta invalida ao carregar funcionarios.',
        );
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Funcionario.fromJson)
          .where((employee) => employee.codigo > 0 && employee.nome.isNotEmpty)
          .toList();
    } on EmployeeRepositoryException {
      rethrow;
    } on FormatException catch (error) {
      throw EmployeeRepositoryException(
        'Resposta invalida ao carregar funcionarios: ${error.message}',
      );
    } catch (error) {
      throw EmployeeRepositoryException(
        'Nao foi possivel carregar funcionarios: $error',
      );
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  Future<Funcionario?> validateDeletePassword(String password) async {
    final client = _client ?? http.Client();

    try {
      final response = await client
          .post(
            config.endpoint('lerSenhas'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=utf-8',
              'Connection': 'Close',
            },
            body: jsonEncode({'senha': password}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw EmployeeRepositoryException(
          'Erro validando senha (${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const EmployeeRepositoryException(
          'Resposta invalida ao validar senha.',
        );
      }

      final authorizations = decoded
          .whereType<Map<String, dynamic>>()
          .map(Funcionario.fromPasswordJson)
          .where((employee) => employee.codigo > 0 && employee.nome.isNotEmpty)
          .toList();

      return authorizations.isEmpty ? null : authorizations.first;
    } on EmployeeRepositoryException {
      rethrow;
    } on FormatException catch (error) {
      throw EmployeeRepositoryException(
        'Resposta invalida ao validar senha: ${error.message}',
      );
    } catch (error) {
      throw EmployeeRepositoryException(
        'Nao foi possivel validar senha: $error',
      );
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}

class EmployeeRepositoryException implements Exception {
  const EmployeeRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
