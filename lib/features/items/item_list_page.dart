import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/models/empresa_config.dart';
import '../../core/models/funcionario.dart';
import '../../core/models/item_comanda.dart';
import '../../core/models/produto.dart';
import '../../core/widgets/operational_keyboard.dart';
import '../commands/command_selection.dart';
import '../employees/employee_repository.dart';
import '../products/product_options_page.dart';
import '../products/product_repository.dart';
import '../products/product_search_page.dart';
import 'item_repository.dart';

const _itemColor = Color(0xFF4169E1);

class ItemListPage extends StatefulWidget {
  const ItemListPage({
    super.key,
    required this.config,
    required this.employee,
    required this.command,
    this.companyConfig,
    ItemRepository? repository,
  }) : _repository = repository;

  final AppConfig config;
  final Funcionario employee;
  final CommandSelection command;
  final EmpresaConfig? companyConfig;
  final ItemRepository? _repository;

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  late Future<List<ItemComanda>> _itemsFuture;
  bool _adding = false;
  bool _busy = false;

  ItemRepository get _repository {
    return widget._repository ?? ItemRepository(config: widget.config);
  }

  @override
  void initState() {
    super.initState();
    _itemsFuture = _repository.fetchItems(widget.command.codigoComanda);
  }

  void _reload() {
    setState(() {
      _itemsFuture = _repository.fetchItems(widget.command.codigoComanda);
    });
  }

  Future<void> _addItem() async {
    if (widget.command.estaBloqueada || _adding || _busy) {
      return;
    }

    Produto? product;
    if (widget.config.physicalKeyboardEnabled) {
      final navigator = Navigator.of(context);
      product = await navigator.push<Produto>(
        MaterialPageRoute(
          builder: (_) => ProductSearchPage(config: widget.config),
        ),
      );
    } else {
      product = await _askProduct();
    }

    if (product == null || !mounted) {
      return;
    }
    final selectedProduct = product;

    _ItemDraft? draft;
    if (widget.config.physicalKeyboardEnabled) {
      draft = await showDialog<_ItemDraft>(
        context: context,
        builder: (_) => _ItemDraftDialog(product: selectedProduct),
      );
    } else {
      draft = await _askItemDraft(selectedProduct);
    }

    if (draft == null || draft.quantity <= 0 || !mounted) {
      return;
    }

    setState(() {
      _adding = true;
    });

    List<Produto> acompanhamentos = const [];
    List<Produto> adicionais = const [];

    try {
      final productRepository = ProductRepository(config: widget.config);
      acompanhamentos = await productRepository.fetchAcompanhamentos(
        selectedProduct.codigo,
      );
      adicionais = await productRepository.fetchAdicionais(
        selectedProduct.codigo,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
        setState(() {
          _adding = false;
        });
      }
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _adding = false;
    });

    final selectedAcompanhamentos = await _selectOptions(
      title: 'Acompanhamentos',
      options: acompanhamentos,
    );
    if (selectedAcompanhamentos == null || !mounted) {
      return;
    }

    final selectedAdicionais = await _selectOptions(
      title: 'Adicionais',
      options: adicionais,
    );
    if (selectedAdicionais == null || !mounted) {
      return;
    }

    setState(() {
      _adding = true;
    });

    try {
      for (final acompanhamento in selectedAcompanhamentos) {
        await _repository.addItem(
          employee: widget.employee,
          command: widget.command,
          product: acompanhamento,
          quantity: 1,
        );
      }

      for (final adicional in selectedAdicionais) {
        await _repository.addItem(
          employee: widget.employee,
          command: widget.command,
          product: adicional,
          quantity: 1,
        );
      }

      await _repository.addItem(
        employee: widget.employee,
        command: widget.command,
        product: selectedProduct,
        quantity: draft.quantity,
        observation: draft.observation,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selectedProduct.descricao} incluido')),
      );
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _adding = false;
        });
      }
    }
  }

  Future<void> _changeObservation(ItemComanda item) async {
    if (widget.command.estaBloqueada || _busy) {
      return;
    }

    final observation = await _askObservation(initialValue: item.observacao);

    if (observation == null || !mounted) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await _repository.updateObservation(
        employee: widget.employee,
        command: widget.command,
        item: item,
        observation: observation,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Observacao alterada')));
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _deleteItem(ItemComanda item) async {
    if (widget.command.estaBloqueada || _busy) {
      return;
    }

    final confirmed = await _confirmDelete(item);
    if (confirmed != true || !mounted) {
      return;
    }

    Funcionario authorizedEmployee = widget.employee;
    if (widget.config.requirePasswordToDelete) {
      final password = await _askPassword();

      if (password == null || password.isEmpty || !mounted) {
        return;
      }

      setState(() {
        _busy = true;
      });

      try {
        final employeeRepository = EmployeeRepository(config: widget.config);
        final authorization = await employeeRepository.validateDeletePassword(
          password,
        );

        if (!mounted) {
          return;
        }

        if (authorization == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Senha invalida')));
          return;
        }

        authorizedEmployee = authorization;
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        }
        return;
      } finally {
        if (mounted) {
          setState(() {
            _busy = false;
          });
        }
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await _repository.deleteItem(
        employee: authorizedEmployee,
        command: widget.command,
        item: item,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item excluido')));
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _changeItemCommand(ItemComanda item) async {
    if (widget.command.estaBloqueada || _busy) {
      return;
    }

    final authorizedEmployee = await _authorizeTrade();
    if (authorizedEmployee == null || !mounted) {
      return;
    }

    final novaComanda = await _askNumber(
      title: 'informe a nova comanda',
      invalidMessage: 'Informe uma comanda valida',
      color: const Color(0xFF35B779),
    );

    if (novaComanda == null || !mounted) {
      return;
    }

    if (novaComanda == widget.command.codigoComanda) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A nova comanda deve ser diferente da atual.'),
        ),
      );
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await _repository.changeItemCommand(
        employee: authorizedEmployee,
        command: widget.command,
        item: item,
        novaComanda: novaComanda,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.descricaoProduto} transferido')),
      );
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<Funcionario?> _authorizeTrade() async {
    final policy = widget.companyConfig?.controlaTroca;
    switch (policy) {
      case TrocaComandaPolicy.desabilitada:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Operacao desabilitada. Nao e possivel fazer a troca.',
            ),
          ),
        );
        return null;
      case TrocaComandaPolicy.exigeSenha:
        final password = await _askPassword();

        if (password == null || password.isEmpty || !mounted) {
          return null;
        }

        setState(() {
          _busy = true;
        });

        try {
          final employeeRepository = EmployeeRepository(config: widget.config);
          final authorization = await employeeRepository.validateDeletePassword(
            password,
          );

          if (!mounted) {
            return null;
          }

          if (authorization == null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Senha invalida')));
            return null;
          }

          return authorization;
        } catch (error) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error.toString())));
          }
          return null;
        } finally {
          if (mounted) {
            setState(() {
              _busy = false;
            });
          }
        }
      case TrocaComandaPolicy.livre:
      case null:
        return widget.employee;
    }
  }

  Future<bool?> _confirmDelete(ItemComanda item) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir item'),
        content: Text('Excluir ${item.descricaoProduto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<List<Produto>?> _selectOptions({
    required String title,
    required List<Produto> options,
  }) async {
    if (options.isEmpty) {
      return const [];
    }

    return Navigator.of(context).push<List<Produto>>(
      MaterialPageRoute(
        builder: (_) => ProductOptionsPage(title: title, options: options),
      ),
    );
  }

  Future<_ItemDraft?> _askItemDraft(Produto product) async {
    final quantityResult = await showOperationalKeyboard(
      context: context,
      title: 'informe a quantidade',
      initialValue: '1',
      mode: OperationalKeyboardMode.numeric,
      color: const Color(0xFFE53935),
      allowDecimal: product.permiteQuantidadeDecimal,
      replaceInitialValueOnFirstInput: true,
    );

    if (quantityResult == null ||
        quantityResult.action == OperationalKeyboardAction.back) {
      return null;
    }

    final normalized = quantityResult.value.replaceAll(',', '.');
    final quantity = double.tryParse(normalized);
    if (quantity == null || quantity <= 0) {
      _showMessage('Informe uma quantidade valida');
      return null;
    }

    if (!product.permiteQuantidadeDecimal && quantity % 1 != 0) {
      _showMessage('Este produto aceita apenas quantidade inteira');
      return null;
    }

    final observation = await _askObservation(initialValue: '');
    if (!mounted) {
      return null;
    }

    return _ItemDraft(quantity: quantity, observation: observation ?? '');
  }

  Future<Produto?> _askProduct() async {
    final productRepository = ProductRepository(config: widget.config);
    Future<String?> previewProduct(String value) async {
      final product = await _findProduct(
        productRepository,
        value,
        silent: true,
      );
      if (product == null) {
        return null;
      }

      final price = product.valorUnitario.toStringAsFixed(2);
      return '${product.codigo} - ${product.descricao}  R\$ $price';
    }

    final result = await showOperationalKeyboard(
      context: context,
      title: 'informe o produto',
      initialValue: '',
      mode: OperationalKeyboardMode.numeric,
      color: _itemColor,
      allowAlphaSwitch: true,
      showListAction: true,
      previewLoader: previewProduct,
    );

    if (result == null ||
        result.action == OperationalKeyboardAction.back ||
        result.action == OperationalKeyboardAction.list) {
      return null;
    }

    final product = await _findProduct(productRepository, result.value);
    if (product == null) {
      _showMessage('Produto nao encontrado');
      return null;
    }

    return product;
  }

  Future<Produto?> _findProduct(
    ProductRepository repository,
    String value, {
    bool silent = false,
  }) async {
    final query = value.trim();
    if (query.isEmpty) {
      return null;
    }

    try {
      final products = await repository.searchProducts(
        query,
        mode: ProductSearchMode.item,
      );
      return products.isEmpty ? null : products.first;
    } catch (error) {
      if (mounted && !silent) {
        _showMessage(error.toString());
      }
      return null;
    }
  }

  Future<int?> _askNumber({
    required String title,
    required String invalidMessage,
    required Color color,
  }) async {
    if (widget.config.physicalKeyboardEnabled) {
      return showDialog<int>(
        context: context,
        builder: (_) => _NumberDialog(
          title: title,
          label: title,
          icon: Icons.receipt_long_outlined,
          invalidMessage: invalidMessage,
        ),
      );
    }

    final result = await showOperationalKeyboard(
      context: context,
      title: title,
      initialValue: '',
      mode: OperationalKeyboardMode.numeric,
      color: color,
    );

    if (result == null || result.action == OperationalKeyboardAction.back) {
      return null;
    }

    final value = int.tryParse(result.value);
    if (value == null || value <= 0) {
      _showMessage(invalidMessage);
      return null;
    }

    return value;
  }

  Future<String?> _askPassword() async {
    if (widget.config.physicalKeyboardEnabled) {
      return showDialog<String>(
        context: context,
        builder: (_) => const _PasswordDialog(),
      );
    }

    final result = await showOperationalKeyboard(
      context: context,
      title: 'informe a senha',
      initialValue: '',
      mode: OperationalKeyboardMode.numeric,
      color: const Color(0xFF8E8E8E),
      obscure: true,
    );

    if (result == null || result.action == OperationalKeyboardAction.back) {
      return null;
    }

    return result.value;
  }

  Future<String?> _askObservation({required String initialValue}) async {
    if (widget.config.physicalKeyboardEnabled) {
      return showDialog<String>(
        context: context,
        builder: (_) => _ObservationDialog(initialValue: initialValue),
      );
    }

    final result = await showOperationalKeyboard(
      context: context,
      title: 'informe a observacao',
      initialValue: initialValue,
      mode: OperationalKeyboardMode.alpha,
      color: const Color(0xFF8E8E8E),
    );

    if (result == null || result.action == OperationalKeyboardAction.back) {
      return initialValue.isEmpty ? '' : null;
    }

    return result.value;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itens'),
        backgroundColor: _itemColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.command.estaBloqueada || _adding || _busy
            ? null
            : _addItem,
        backgroundColor: _itemColor,
        foregroundColor: Colors.white,
        icon: _adding || _busy
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<ItemComanda>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ItemError(
                message: snapshot.error.toString(),
                onRetry: _reload,
              );
            }

            final items = snapshot.data ?? const <ItemComanda>[];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _ItemHeader(
                    employee: widget.employee,
                    command: widget.command,
                    itemCount: items.length,
                    total: items.fold<double>(
                      0,
                      (sum, item) => sum + item.valorTotal,
                    ),
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? _ItemError(
                          message: 'Nenhum item encontrado para esta comanda.',
                          onRetry: _reload,
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          children: [
                            ...items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _ItemTile(
                                  item: item,
                                  enabled:
                                      !widget.command.estaBloqueada && !_busy,
                                  onChangeCommand: () =>
                                      _changeItemCommand(item),
                                  onChangeObservation: () =>
                                      _changeObservation(item),
                                  onDelete: () => _deleteItem(item),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _NumberDialog extends StatefulWidget {
  const _NumberDialog({
    required this.title,
    required this.label,
    required this.icon,
    required this.invalidMessage,
  });

  final String title;
  final String label;
  final IconData icon;
  final String invalidMessage;

  @override
  State<_NumberDialog> createState() => _NumberDialogState();
}

class _NumberDialogState extends State<_NumberDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value <= 0) {
      setState(() {
        _error = widget.invalidMessage;
      });
      return;
    }

    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _confirm(),
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: Icon(widget.icon),
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirm, child: const Text('Confirmar')),
      ],
    );
  }
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Senha'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _confirm(),
        decoration: const InputDecoration(
          labelText: 'Senha autorizada',
          prefixIcon: Icon(Icons.password_outlined),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirm, child: const Text('Confirmar')),
      ],
    );
  }
}

class _ObservationDialog extends StatefulWidget {
  const _ObservationDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_ObservationDialog> createState() => _ObservationDialogState();
}

class _ObservationDialogState extends State<_ObservationDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Observacao'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 3,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Observacao do item',
          prefixIcon: Icon(Icons.notes_outlined),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirm, child: const Text('Salvar')),
      ],
    );
  }
}

class _ItemDraft {
  const _ItemDraft({required this.quantity, required this.observation});

  final double quantity;
  final String observation;
}

class _ItemDraftDialog extends StatefulWidget {
  const _ItemDraftDialog({required this.product});

  final Produto product;

  @override
  State<_ItemDraftDialog> createState() => _ItemDraftDialogState();
}

class _ItemDraftDialogState extends State<_ItemDraftDialog> {
  late final TextEditingController _quantityController;
  late final TextEditingController _observationController;
  String? _quantityError;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
    _quantityController.selection = const TextSelection(
      baseOffset: 0,
      extentOffset: 1,
    );
    _observationController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  void _confirm() {
    final normalized = _quantityController.text.trim().replaceAll(',', '.');
    final quantity = double.tryParse(normalized);

    if (quantity == null || quantity <= 0) {
      setState(() {
        _quantityError = 'Informe uma quantidade valida';
      });
      return;
    }

    if (!widget.product.permiteQuantidadeDecimal && quantity % 1 != 0) {
      setState(() {
        _quantityError = 'Este produto aceita apenas quantidade inteira';
      });
      return;
    }

    Navigator.of(context).pop(
      _ItemDraft(
        quantity: quantity,
        observation: _observationController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Adicionar item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product.descricao),
            const SizedBox(height: 4),
            Text(
              'R\$ ${widget.product.valorUnitario.toStringAsFixed(2)} / ${widget.product.unidade}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: widget.product.permiteQuantidadeDecimal
                    ? 'Quantidade decimal'
                    : 'Quantidade',
                prefixIcon: const Icon(Icons.numbers_outlined),
                errorText: _quantityError,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _observationController,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Observacao',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirm, child: const Text('Incluir')),
      ],
    );
  }
}

class _ItemHeader extends StatelessWidget {
  const _ItemHeader({
    required this.employee,
    required this.command,
    required this.itemCount,
    required this.total,
  });

  final Funcionario employee;
  final CommandSelection command;
  final int itemCount;
  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(command.resumo, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              employee.nome,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _HeaderMetric(label: 'Itens', value: itemCount.toString()),
                const SizedBox(width: 12),
                _HeaderMetric(
                  label: 'Total',
                  value: 'R\$ ${total.toStringAsFixed(2)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.enabled,
    required this.onChangeCommand,
    required this.onChangeObservation,
    required this.onDelete,
  });

  final ItemComanda item;
  final bool enabled;
  final VoidCallback onChangeCommand;
  final VoidCallback onChangeObservation;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barcode = item.codigoBarra == '0000000000000' ? '' : item.codigoBarra;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ItemThreeColumns(
              columns: [
                _ItemInfoColumn(
                  label: 'Qtde',
                  value: item.quantidade.toStringAsFixed(3),
                ),
                _ItemInfoColumn(
                  label: 'Unitario R\$',
                  value: item.valorUnitario.toStringAsFixed(2),
                  align: TextAlign.center,
                ),
                _ItemInfoColumn(
                  label: 'Total R\$',
                  value: item.valorTotal.toStringAsFixed(2),
                  align: TextAlign.right,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ItemThreeColumns(
              columns: [
                _ItemInfoColumn(
                  label: 'Produto',
                  value: item.codigoProduto.toString(),
                  color: _itemColor,
                  pill: true,
                ),
                _ItemInfoColumn(
                  label: 'Reduzido',
                  value: item.codigoReduzido > 0
                      ? item.codigoReduzido.toString()
                      : '',
                  align: TextAlign.center,
                ),
                _ItemInfoColumn(
                  label: 'Barra',
                  value: barcode,
                  align: TextAlign.right,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ItemInfoBlock(label: 'Descricao', value: item.descricaoProduto),
            if (item.observacao.isNotEmpty) ...[
              const SizedBox(height: 10),
              _ItemInfoBlock(
                label: 'Observacao',
                value: item.observacao,
                valueStyle: theme.textTheme.bodySmall,
              ),
            ],
            if (item.nomeFuncionario.isNotEmpty ||
                item.dataHora.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.nomeFuncionario.isNotEmpty)
                          _ItemInfoBlock(
                            label: 'Funcionario',
                            value: item.nomeFuncionario,
                            valueStyle: theme.textTheme.bodySmall,
                          ),
                        if (item.dataHora.isNotEmpty)
                          Text(
                            item.dataHora,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFFFF3030),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _ItemActionMenu(
                    enabled: enabled,
                    onChangeCommand: onChangeCommand,
                    onChangeObservation: onChangeObservation,
                    onDelete: onDelete,
                  ),
                ],
              ),
            ] else
              Align(
                alignment: Alignment.centerRight,
                child: _ItemActionMenu(
                  enabled: enabled,
                  onChangeCommand: onChangeCommand,
                  onChangeObservation: onChangeObservation,
                  onDelete: onDelete,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _ItemAction { changeCommand, observation, delete }

class _ItemActionMenu extends StatelessWidget {
  const _ItemActionMenu({
    required this.enabled,
    required this.onChangeCommand,
    required this.onChangeObservation,
    required this.onDelete,
  });

  final bool enabled;
  final VoidCallback onChangeCommand;
  final VoidCallback onChangeObservation;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ItemAction>(
      enabled: enabled,
      onSelected: (action) {
        switch (action) {
          case _ItemAction.changeCommand:
            onChangeCommand();
          case _ItemAction.observation:
            onChangeObservation();
          case _ItemAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _ItemAction.changeCommand,
          child: ListTile(
            leading: Icon(Icons.swap_horiz_outlined),
            title: Text('Trocar comanda'),
          ),
        ),
        PopupMenuItem(
          value: _ItemAction.observation,
          child: ListTile(
            leading: Icon(Icons.notes_outlined),
            title: Text('Alterar observacao'),
          ),
        ),
        PopupMenuItem(
          value: _ItemAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Excluir item'),
          ),
        ),
      ],
    );
  }
}

class _ItemThreeColumns extends StatelessWidget {
  const _ItemThreeColumns({required this.columns});

  final List<_ItemInfoColumn> columns;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final column in columns) Expanded(child: column)],
    );
  }
}

class _ItemInfoColumn extends StatelessWidget {
  const _ItemInfoColumn({
    required this.label,
    required this.value,
    this.align = TextAlign.left,
    this.color = const Color(0xFF27408B),
    this.pill = false,
  });

  final String label;
  final String value;
  final TextAlign align;
  final Color color;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: align == TextAlign.right
          ? CrossAxisAlignment.end
          : align == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: align,
          style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 2),
        if (pill)
          _ItemCodePill(code: value, color: color)
        else
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: align,
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
      ],
    );
  }
}

class _ItemCodePill extends StatelessWidget {
  const _ItemCodePill({required this.code, required this.color});

  final String code;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 72,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
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

class _ItemInfoBlock extends StatelessWidget {
  const _ItemInfoBlock({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: valueStyle ?? theme.textTheme.titleMedium),
      ],
    );
  }
}

class _ItemError extends StatelessWidget {
  const _ItemError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.format_list_bulleted_outlined,
              size: 42,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
