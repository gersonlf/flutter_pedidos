import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/models/produto.dart';
import '../../core/widgets/operational_keyboard.dart';
import 'product_repository.dart';

const _productColor = Color(0xFFE53935);

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

  ProductSearchMode get _searchMode {
    return widget.selectionEnabled
        ? ProductSearchMode.item
        : ProductSearchMode.list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um produto para pesquisar.')),
      );
      return;
    }

    setState(() {
      _productsFuture = _repository.searchProducts(
        _searchController.text,
        mode: _searchMode,
      );
    });
  }

  Future<String?> _previewProduct(String value) async {
    final query = value.trim();
    if (query.isEmpty) {
      return null;
    }

    final products = await _repository.searchProducts(query, mode: _searchMode);
    if (products.isEmpty) {
      return null;
    }

    final product = products.first;
    final price = product.valorUnitario.toStringAsFixed(2);
    return '${product.codigo} - ${product.descricao}  R\$ $price';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectionEnabled ? 'Produtos' : 'Consulta de Produtos',
        ),
        backgroundColor: _productColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _ProductSearchCard(
                controller: _searchController,
                useSystemKeyboard: widget.config.physicalKeyboardEnabled,
                onSearch: _search,
                previewLoader: _previewProduct,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _productsFuture == null
                    ? const _ProductMessage(
                        icon: Icons.search_outlined,
                        message:
                            'Pesquise por descricao, codigo ou codigo de barras.',
                      )
                    : FutureBuilder<List<Produto>>(
                        future: _productsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
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

                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _ProductTile(
                                  product: product,
                                  selectionEnabled: widget.selectionEnabled,
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSearchCard extends StatelessWidget {
  const _ProductSearchCard({
    required this.controller,
    required this.useSystemKeyboard,
    required this.onSearch,
    required this.previewLoader,
  });

  final TextEditingController controller;
  final bool useSystemKeyboard;
  final VoidCallback onSearch;
  final OperationalKeyboardPreviewLoader previewLoader;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final field = OperationalKeyboardTextField(
              controller: controller,
              useSystemKeyboard: useSystemKeyboard,
              title: 'informe o produto',
              labelText: 'Produto, codigo ou barras',
              prefixIcon: Icons.search_outlined,
              mode: OperationalKeyboardMode.numeric,
              color: _productColor,
              allowAlphaSwitch: true,
              clearOnOpen: true,
              textInputAction: TextInputAction.search,
              showListAction: true,
              onConfirm: onSearch,
              onList: onSearch,
              previewLoader: previewLoader,
            );
            final button = useSystemKeyboard
                ? FilledButton.icon(
                    onPressed: onSearch,
                    style: FilledButton.styleFrom(
                      backgroundColor: _productColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.search),
                    label: const Text('Pesquisar'),
                  )
                : null;

            if (constraints.maxWidth < 420) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  field,
                  if (button != null) ...[const SizedBox(height: 12), button],
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: field),
                if (button != null) ...[const SizedBox(width: 12), button],
              ],
            );
          },
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
        color: _productColor,
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
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
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
