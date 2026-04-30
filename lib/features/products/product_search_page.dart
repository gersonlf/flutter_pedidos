import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/models/produto.dart';
import 'product_repository.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({
    super.key,
    required this.config,
    this.selectionEnabled = true,
    ProductRepository? repository,
  }) : _repository = repository;

  final AppConfig config;
  final bool selectionEnabled;
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
      appBar: AppBar(
        title: Text(
          widget.selectionEnabled ? 'Produtos' : 'Consulta de Produtos',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final field = TextField(
                      controller: _searchController,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      decoration: const InputDecoration(
                        labelText: 'Produto, codigo ou barras',
                        prefixIcon: Icon(Icons.search_outlined),
                      ),
                    );
                    final button = FilledButton.icon(
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                      label: const Text('Pesquisar'),
                    );

                    if (constraints.maxWidth < 420) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [field, const SizedBox(height: 12), button],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: field),
                        const SizedBox(width: 12),
                        button,
                      ],
                    );
                  },
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
                            child: _ProductTile(
                              product: product,
                              selectionEnabled: widget.selectionEnabled,
                            ),
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
  const _ProductTile({required this.product, required this.selectionEnabled});

  final Produto product;
  final bool selectionEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: selectionEnabled
            ? () => Navigator.of(context).pop(product)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _ProductCodePill(code: product.codigo.toString()),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.descricao, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (product.codigoReduzido > 0)
                          'Red. ${product.codigoReduzido}',
                        if (product.codigoBarra.isNotEmpty) product.codigoBarra,
                        product.unidade,
                      ].join(' - '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'R\$ ${product.valorUnitario.toStringAsFixed(2)}',
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCodePill extends StatelessWidget {
  const _ProductCodePill({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 72,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            code,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
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
