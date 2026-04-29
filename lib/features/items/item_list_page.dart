import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/models/empresa_config.dart';
import '../../core/models/funcionario.dart';
import '../../core/models/item_comanda.dart';
import '../../core/models/produto.dart';
import '../commands/command_selection.dart';
import '../employees/employee_repository.dart';
import '../kitchen/kitchen_repository.dart';
import '../products/product_options_page.dart';
import '../products/product_repository.dart';
import '../products/product_search_page.dart';
import 'item_repository.dart';

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

    final product = await Navigator.of(context).push<Produto>(
      MaterialPageRoute(
        builder: (_) => ProductSearchPage(config: widget.config),
      ),
    );

    if (product == null || !mounted) {
      return;
    }

    final draft = await showDialog<_ItemDraft>(
      context: context,
      builder: (_) => _ItemDraftDialog(product: product),
    );

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
        product.codigo,
      );
      adicionais = await productRepository.fetchAdicionais(product.codigo);
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
        product: product,
        quantity: draft.quantity,
        observation: draft.observation,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${product.descricao} incluido')));
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

    final observation = await showDialog<String>(
      context: context,
      builder: (_) => _ObservationDialog(initialValue: item.observacao),
    );

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
      final password = await showDialog<String>(
        context: context,
        builder: (_) => const _PasswordDialog(),
      );

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

    final novaComanda = await showDialog<int>(
      context: context,
      builder: (_) => _NumberDialog(
        title: 'Trocar item de comanda',
        label: 'Nova comanda',
        icon: Icons.receipt_long_outlined,
        invalidMessage: 'Informe uma comanda valida',
      ),
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
        final password = await showDialog<String>(
          context: context,
          builder: (_) => const _PasswordDialog(),
        );

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

  Future<void> _sendToKitchen() async {
    if (_busy || widget.companyConfig?.controlaCozinha == false) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final repository = KitchenRepository(config: widget.config);
      await repository.sendCommandToKitchen(
        employee: widget.employee,
        codigoComanda: widget.command.codigoComanda,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Comanda enviada')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itens ${widget.command.codigoComanda}'),
        actions: [
          IconButton(
            tooltip: 'Enviar para cozinha',
            onPressed: _busy || widget.companyConfig?.controlaCozinha == false
                ? null
                : _sendToKitchen,
            icon: const Icon(Icons.restaurant_outlined),
          ),
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

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _ItemHeader(
                  employee: widget.employee,
                  command: widget.command,
                  itemCount: items.length,
                  total: items.fold<double>(
                    0,
                    (sum, item) => sum + item.valorTotal,
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  _ItemError(
                    message: 'Nenhum item encontrado para esta comanda.',
                    onRetry: _reload,
                  )
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ItemTile(
                        item: item,
                        enabled: !widget.command.estaBloqueada && !_busy,
                        onChangeCommand: () => _changeItemCommand(item),
                        onChangeObservation: () => _changeObservation(item),
                        onDelete: () => _deleteItem(item),
                      ),
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

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(item.itemVenda.toString())),
        title: Text(item.descricaoProduto),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.quantidade.toStringAsFixed(3)} x R\$ ${item.valorUnitario.toStringAsFixed(2)}',
            ),
            if (item.observacao.isNotEmpty)
              Text(
                item.observacao,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'R\$ ${item.valorTotal.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall,
            ),
            PopupMenuButton<_ItemAction>(
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
            ),
          ],
        ),
      ),
    );
  }
}

enum _ItemAction { changeCommand, observation, delete }

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
