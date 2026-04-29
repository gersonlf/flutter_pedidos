import 'package:flutter/material.dart';

import '../../core/models/produto.dart';

class ProductOptionsPage extends StatefulWidget {
  const ProductOptionsPage({
    super.key,
    required this.title,
    required this.options,
  });

  final String title;
  final List<Produto> options;

  @override
  State<ProductOptionsPage> createState() => _ProductOptionsPageState();
}

class _ProductOptionsPageState extends State<ProductOptionsPage> {
  final Set<int> _selectedCodes = {};

  List<Produto> get _selectedOptions {
    return widget.options
        .where((option) => _selectedCodes.contains(option.codigo))
        .toList();
  }

  void _toggle(Produto product, bool selected) {
    setState(() {
      if (selected) {
        _selectedCodes.add(product.codigo);
      } else {
        _selectedCodes.remove(product.codigo);
      }
    });
  }

  void _finish() {
    Navigator.of(context).pop(_selectedOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(onPressed: _finish, child: const Text('Concluir')),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: widget.options.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final product = widget.options[index];
            final selected = _selectedCodes.contains(product.codigo);

            return Card(
              child: CheckboxListTile(
                value: selected,
                onChanged: (value) => _toggle(product, value ?? false),
                title: Text(product.descricao),
                subtitle: Text(_subtitle(product)),
                secondary: CircleAvatar(child: Text(product.codigo.toString())),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _finish,
        icon: const Icon(Icons.check),
        label: Text('Concluir (${_selectedCodes.length})'),
      ),
    );
  }

  String _subtitle(Produto product) {
    final parts = <String>[
      if (product.valorUnitario > 0)
        'R\$ ${product.valorUnitario.toStringAsFixed(2)}'
      else
        'Sem valor adicional',
      product.unidade,
      if (product.quantidadeAcompanhamento > 0)
        'Limite ${product.quantidadeAcompanhamento}',
    ];

    return parts.join(' - ');
  }
}
