import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/models/empresa_config.dart';
import '../../core/network/api_client.dart';

class CompanyRepository {
  const CompanyRepository({required this.config, http.Client? client})
    : _client = client;

  final AppConfig config;
  final http.Client? _client;

  Future<EmpresaConfig> fetchCompanyConfig() async {
    try {
      final decoded = await ApiClient(config: config, client: _client).postJson(
        scriptName: 'lerEmpresas',
        body: const <String, Object?>{},
        failureMessage: 'Nao foi possivel carregar regras da empresa',
        invalidMessage: 'Resposta invalida ao carregar regras da empresa.',
        allowEmptyResponse: false,
      );

      if (decoded is! List || decoded.isEmpty) {
        throw const CompanyRepositoryException(
          'Resposta invalida ao carregar regras da empresa.',
        );
      }

      final first = decoded.first;
      if (first is! Map<String, dynamic>) {
        throw const CompanyRepositoryException(
          'Resposta invalida ao carregar regras da empresa.',
        );
      }

      return EmpresaConfig.fromJson(first);
    } on CompanyRepositoryException {
      rethrow;
    } on ApiClientException catch (error) {
      throw CompanyRepositoryException(error.message);
    } catch (error) {
      throw CompanyRepositoryException(
        'Nao foi possivel carregar regras da empresa: $error',
      );
    }
  }
}

class CompanyRepositoryException implements Exception {
  const CompanyRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
