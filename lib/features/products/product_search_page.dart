import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/models/produto.dart';
import 'product_repository.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({
    super.key,
    required this.config,
    ProductRepository? repository,
  }) : _repository = repository;

  final AppConfig config;
  final ProductRepository? _repository;

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final _searchController = TextEditingController();
  Future<List<Produto>>? _productsFuture;

  ProductRepository get _repository {
    return widget._repository ?? ProductRepository(config: widget.config);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    setState(() {
      _productsFuture = _repository.searchProducts(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _search(),
                        decoration: const InputDecoration(
                          labelText: 'Produto, codigo ou barras',
                          prefixIcon: Icon(Icons.search_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      tooltip: 'Pesquisar',
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_productsFuture == null)
              const _ProductMessage(
                icon: Icons.search_outlined,
                message: 'Pesquise por descricao, codigo ou codigo de barras.',
              )
            else
              FutureBuilder<List<Produto>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return _ProductMessage(
                      icon: Icons.error_outline,
                      message: snapshot.error.toString(),
                    );
                  }

                  final products = snapshot.data ?? const <Produto>[];
                  if (products.isEmpty) {
                    return const _ProductMessage(
                      icon: Icons.inventory_2_outlined,
                      message: 'Nenhum produto encontrado.',
                    );
                  }

                  return Column(
                    children: products
                        .map(
                          (product) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ProductTile(product: product),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});

  final Produto product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(product.codigo.toString())),
        title: Text(product.descricao),
        subtitle: Text(
          [
            if (product.codigoReduzido > 0) 'Red. ${product.codigoReduzido}',
            if (product.codigoBarra.isNotEmpty) product.codigoBarra,
            product.unidade,
          ].join(' - '),
        ),
        trailing: Text(
          'R\$ ${product.valorUnitario.toStringAsFixed(2)}',
          style: theme.textTheme.titleSmall,
        ),
        onTap: () => Navigator.of(context).pop(product),
      ),
    );
  }
}

class _ProductMessage extends StatelessWidget {
  const _ProductMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 42, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
