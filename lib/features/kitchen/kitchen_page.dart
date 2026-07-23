import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/models/funcionario.dart';
import '../../core/models/pedido_cozinha.dart';
import '../../core/widgets/operational_keyboard.dart';
import 'kitchen_repository.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({
    super.key,
    required this.config,
    required this.employee,
    KitchenRepository? repository,
  }) : _repository = repository;

  final AppConfig config;
  final Funcionario employee;
  final KitchenRepository? _repository;

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  final _commandController = TextEditingController();
  late Future<List<PedidoCozinha>> _readyFuture;
  late Future<List<PedidoCozinha>> _deliveredFuture;
  bool _busy = false;

  KitchenRepository get _repository {
    return widget._repository ?? KitchenRepository(config: widget.config);
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _readyFuture = _repository.fetchOrders(PedidoCozinhaTipo.pronto);
      _deliveredFuture = _repository.fetchOrders(PedidoCozinhaTipo.entregue);
    });
  }

  Future<void> _callTypedCommand() async {
    final codigoComanda = int.tryParse(_commandController.text.trim());
    if (codigoComanda == null || codigoComanda <= 0) {
      _showMessage('Informe uma comanda valida.');
      return;
    }

    await _callOrder(codigoComanda);
  }

  Future<void> _callOrder(int codigoComanda) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await _repository.callReadyOrder(
        employee: widget.employee,
        codigoComanda: codigoComanda,
      );

      if (!mounted) {
        return;
      }

      _commandController.clear();
      _showMessage('Comanda $codigoComanda chamada');
      _reload();
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _removeOrder(int codigoComanda) async {
    if (_busy) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover chamada'),
        content: Text('Remover a comanda $codigoComanda da cozinha?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await _repository.removeDeliveredOrder(
        employee: widget.employee,
        codigoComanda: codigoComanda,
      );

      if (!mounted) {
        return;
      }

      _showMessage('Comanda $codigoComanda removida');
      _reload();
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cozinha'),
          actions: [
            IconButton(
              tooltip: 'Atualizar',
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Prontos'),
              Tab(text: 'Entregues'),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _KitchenInputCard(
                controller: _commandController,
                employee: widget.employee,
                useSystemKeyboard: widget.config.physicalKeyboardEnabled,
                busy: _busy,
                onCall: _callTypedCommand,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _KitchenOrderList(
                      future: _readyFuture,
                      emptyMessage: 'Nenhum pedido pronto encontrado.',
                      actionLabel: 'Chamar',
                      actionIcon: Icons.campaign_outlined,
                      busy: _busy,
                      onAction: _callOrder,
                      onRetry: _reload,
                    ),
                    _KitchenOrderList(
                      future: _deliveredFuture,
                      emptyMessage: 'Nenhum pedido entregue encontrado.',
                      actionLabel: 'Remover',
                      actionIcon: Icons.done_all_outlined,
                      busy: _busy,
                      onAction: _removeOrder,
                      onRetry: _reload,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KitchenInputCard extends StatelessWidget {
  const _KitchenInputCard({
    required this.controller,
    required this.employee,
    required this.useSystemKeyboard,
    required this.busy,
    required this.onCall,
  });

  final TextEditingController controller;
  final Funcionario employee;
  final bool useSystemKeyboard;
  final bool busy;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.restaurant_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      employee.nome,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OperationalKeyboardTextField(
                controller: controller,
                enabled: !busy,
                useSystemKeyboard: useSystemKeyboard,
                title: 'informe a comanda',
                labelText: 'Codigo da comanda',
                prefixIcon: Icons.receipt_long_outlined,
                mode: OperationalKeyboardMode.numeric,
                color: const Color(0xFF35B779),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onConfirm: onCall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: busy ? null : onCall,
                  icon: busy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.campaign_outlined),
                  label: const Text('Chamar comanda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KitchenOrderList extends StatelessWidget {
  const _KitchenOrderList({
    required this.future,
    required this.emptyMessage,
    required this.actionLabel,
    required this.actionIcon,
    required this.busy,
    required this.onAction,
    required this.onRetry,
  });

  final Future<List<PedidoCozinha>> future;
  final String emptyMessage;
  final String actionLabel;
  final IconData actionIcon;
  final bool busy;
  final ValueChanged<int> onAction;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PedidoCozinha>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _KitchenEmptyState(
            message: snapshot.error.toString(),
            onRetry: onRetry,
          );
        }

        final orders = snapshot.data ?? const <PedidoCozinha>[];
        if (orders.isEmpty) {
          return _KitchenEmptyState(message: emptyMessage, onRetry: onRetry);
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: orders.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final order = orders[index];
            return _KitchenOrderTile(
              order: order,
              actionLabel: actionLabel,
              actionIcon: actionIcon,
              enabled: !busy,
              onAction: () => onAction(order.codigoComanda),
            );
          },
        );
      },
    );
  }
}

class _KitchenOrderTile extends StatelessWidget {
  const _KitchenOrderTile({
    required this.order,
    required this.actionLabel,
    required this.actionIcon,
    required this.enabled,
    required this.onAction,
  });

  final PedidoCozinha order;
  final String actionLabel;
  final IconData actionIcon;
  final bool enabled;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final button = FilledButton.icon(
              onPressed: enabled ? onAction : null,
              icon: Icon(actionIcon),
              label: Text(actionLabel),
            );
            final content = Row(
              children: [
                CircleAvatar(child: Text(order.codigoComanda.toString())),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comanda ${order.codigoComanda}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pedido de cozinha',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            if (constraints.maxWidth < 420) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [content, const SizedBox(height: 12), button],
              );
            }

            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 12),
                button,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _KitchenEmptyState extends StatelessWidget {
  const _KitchenEmptyState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.restaurant_outlined,
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
        ),
      ],
    );
  }
}
