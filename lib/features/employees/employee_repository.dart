import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/models/funcionario.dart';
import '../../core/network/api_client.dart';

class EmployeeRepository {
  const EmployeeRepository({required this.config, http.Client? client})
    : _client = client;

  final AppConfig config;
  final http.Client? _client;

  Future<List<Funcionario>> fetchEmployees() async {
    try {
      final decoded = await ApiClient(config: config, client: _client).postJson(
        scriptName: 'lerFuncionarios',
        body: const <String, Object?>{},
        failureMessage: 'Nao foi possivel carregar funcionarios',
        invalidMessage: 'Resposta invalida ao carregar funcionarios.',
        allowEmptyResponse: false,
      );

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
    } on ApiClientException catch (error) {
      throw EmployeeRepositoryException(error.message);
    } catch (error) {
      throw EmployeeRepositoryException(
        'Nao foi possivel carregar funcionarios: $error',
      );
    }
  }

  Future<Funcionario?> validateDeletePassword(String password) async {
    try {
      final decoded = await ApiClient(config: config, client: _client).postJson(
        scriptName: 'lerSenhas',
        body: {'senha': password},
        failureMessage: 'Nao foi possivel validar senha',
        invalidMessage: 'Resposta invalida ao validar senha.',
        allowEmptyResponse: false,
      );

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
    } on ApiClientException catch (error) {
      throw EmployeeRepositoryException(error.message);
    } catch (error) {
      throw EmployeeRepositoryException(
        'Nao foi possivel validar senha: $error',
      );
    }
  }
}

class EmployeeRepositoryException implements Exception {
  const EmployeeRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
