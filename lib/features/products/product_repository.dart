import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/models/produto.dart';
import '../../core/network/api_client.dart';

class ProductRepository {
  const ProductRepository({required this.config, http.Client? client})
    : _client = client;

  final AppConfig config;
  final http.Client? _client;

  Future<List<Produto>> searchProducts(String query) async {
    return _fetchProducts(
      scriptName: 'lerProdutos',
      body: {'consulta_produto': query.trim()},
      emptyMessage: 'Resposta invalida ao carregar produtos.',
      serverErrorPrefix: 'Erro carregando produtos',
      failurePrefix: 'Nao foi possivel carregar produtos',
    );
  }

  Future<List<Produto>> fetchAcompanhamentos(int codigoProduto) async {
    return _fetchProducts(
      scriptName: 'lerAcompanhamentos',
      body: {'consulta_produto': codigoProduto.toString()},
      emptyMessage: 'Resposta invalida ao carregar acompanhamentos.',
      serverErrorPrefix: 'Erro carregando acompanhamentos',
      failurePrefix: 'Nao foi possivel carregar acompanhamentos',
    );
  }

  Future<List<Produto>> fetchAdicionais(int codigoProduto) async {
    return _fetchProducts(
      scriptName: 'lerAdicionais',
      body: {'consulta_produto': codigoProduto.toString()},
      emptyMessage: 'Resposta invalida ao carregar adicionais.',
      serverErrorPrefix: 'Erro carregando adicionais',
      failurePrefix: 'Nao foi possivel carregar adicionais',
    );
  }

  Future<List<Produto>> _fetchProducts({
    required String scriptName,
    required Map<String, String> body,
    required String emptyMessage,
    required String serverErrorPrefix,
    required String failurePrefix,
  }) async {
    try {
      final decoded = await ApiClient(config: config, client: _client).postJson(
        scriptName: scriptName,
        body: body,
        failureMessage: serverErrorPrefix,
        invalidMessage: emptyMessage,
        allowEmptyResponse: false,
      );

      if (decoded is! List) {
        throw ProductRepositoryException(emptyMessage);
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Produto.fromJson)
          .where(
            (product) => product.codigo > 0 && product.descricao.isNotEmpty,
          )
          .toList();
    } on ProductRepositoryException {
      rethrow;
    } on ApiClientException catch (error) {
      throw ProductRepositoryException(error.message);
    } catch (error) {
      throw ProductRepositoryException('$failurePrefix: $error');
    }
  }
}

class ProductRepositoryException implements Exception {
  const ProductRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
