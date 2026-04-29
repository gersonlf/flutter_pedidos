import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/config/app_config_store.dart';
import '../../core/models/funcionario.dart';
import '../commands/command_selection.dart';
import '../commands/command_selection_page.dart';
import '../employees/employee_selection_page.dart';
import '../items/item_list_page.dart';
import '../kitchen/kitchen_page.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.configStore});

  final AppConfigStore configStore;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<AppConfig> _configFuture;
  Funcionario? _selectedEmployee;
  CommandSelection? _selectedCommand;

  @override
  void initState() {
    super.initState();
    _configFuture = widget.configStore.load();
  }

  void _reloadConfig() {
    setState(() {
      _configFuture = widget.configStore.load();
    });
  }

  Future<void> _openSettings(AppConfig config) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          initialConfig: config,
          configStore: widget.configStore,
        ),
      ),
    );

    if (saved == true && mounted) {
      _reloadConfig();
    }
  }

  Future<void> _selectEmployee(AppConfig config) async {
    final employee = await Navigator.of(context).push<Funcionario>(
      MaterialPageRoute(builder: (_) => EmployeeSelectionPage(config: config)),
    );

    if (employee != null && mounted) {
      setState(() {
        _selectedEmployee = employee;
        _selectedCommand = null;
      });
    }
  }

  Future<void> _selectCommand(AppConfig config) async {
    final employee = _selectedEmployee;
    if (employee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um funcionario primeiro.')),
      );
      return;
    }

    final command = await Navigator.of(context).push<CommandSelection>(
      MaterialPageRoute(
        builder: (_) =>
            CommandSelectionPage(config: config, employee: employee),
      ),
    );

    if (command != null && mounted) {
      setState(() {
        _selectedCommand = command.codigoComanda > 0 ? command : null;
      });
    }
  }

  Future<void> _openItems(AppConfig config) async {
    final employee = _selectedEmployee;
    final command = _selectedCommand;

    if (employee == null || command == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione funcionario e comanda.')),
      );
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            ItemListPage(config: config, employee: employee, command: command),
      ),
    );
  }

  Future<void> _openKitchen(AppConfig config) async {
    final employee = _selectedEmployee;

    if (employee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um funcionario primeiro.')),
      );
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => KitchenPage(config: config, employee: employee),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppConfig>(
      future: _configFuture,
      builder: (context, snapshot) {
        final config = snapshot.data ?? AppConfig.defaults();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pedidos Restaurante'),
            actions: [
              IconButton(
                tooltip: 'Configuracoes',
                onPressed: () => _openSettings(config),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : _HomeContent(
                  config: config,
                  selectedEmployee: _selectedEmployee,
                  selectedCommand: _selectedCommand,
                  onConfigure: () => _openSettings(config),
                  onSelectEmployee: () => _selectEmployee(config),
                  onSelectCommand: () => _selectCommand(config),
                  onOpenItems: () => _openItems(config),
                  onOpenKitchen: () => _openKitchen(config),
                ),
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.config,
    required this.selectedEmployee,
    required this.selectedCommand,
    required this.onConfigure,
    required this.onSelectEmployee,
    required this.onSelectCommand,
    required this.onOpenItems,
    required this.onOpenKitchen,
  });

  final AppConfig config;
  final Funcionario? selectedEmployee;
  final CommandSelection? selectedCommand;
  final VoidCallback onConfigure;
  final VoidCallback onSelectEmployee;
  final VoidCallback onSelectCommand;
  final VoidCallback onOpenItems;
  final VoidCallback onOpenKitchen;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ConnectionPanel(config: config, onConfigure: onConfigure),
          const SizedBox(height: 16),
          _EmployeePanel(
            employee: selectedEmployee,
            enabled: config.isServerConfigured,
            onSelectEmployee: onSelectEmployee,
          ),
          const SizedBox(height: 16),
          _CommandPanel(
            command: selectedCommand,
            enabled: config.isServerConfigured && selectedEmployee != null,
            onSelectCommand: onSelectCommand,
          ),
          const SizedBox(height: 16),
          _ModuleGrid(
            configured: config.isServerConfigured,
            hasEmployee: selectedEmployee != null,
            hasCommand: selectedCommand != null,
            onSelectEmployee: onSelectEmployee,
            onSelectCommand: onSelectCommand,
            onOpenItems: onOpenItems,
            onOpenKitchen: onOpenKitchen,
          ),
        ],
      ),
    );
  }
}

class _CommandPanel extends StatelessWidget {
  const _CommandPanel({
    required this.command,
    required this.enabled,
    required this.onSelectCommand,
  });

  final CommandSelection? command;
  final bool enabled;
  final VoidCallback onSelectCommand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(
          command == null
              ? Icons.receipt_long_outlined
              : Icons.assignment_turned_in_outlined,
          color: command == null
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.primary,
        ),
        title: Text(command?.resumo ?? 'Nenhuma comanda selecionada'),
        subtitle: Text(
          command == null
              ? 'Informe ou selecione uma comanda para lancar itens'
              : command!.estaBloqueada
              ? 'Comanda bloqueada'
              : 'Pronta para lancamento de itens',
        ),
        trailing: FilledButton.icon(
          onPressed: enabled ? onSelectCommand : null,
          icon: const Icon(Icons.search_outlined),
          label: const Text('Abrir'),
        ),
      ),
    );
  }
}

class _EmployeePanel extends StatelessWidget {
  const _EmployeePanel({
    required this.employee,
    required this.enabled,
    required this.onSelectEmployee,
  });

  final Funcionario? employee;
  final bool enabled;
  final VoidCallback onSelectEmployee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(
          employee == null ? Icons.badge_outlined : Icons.verified_user,
          color: employee == null
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.primary,
        ),
        title: Text(employee?.nome ?? 'Nenhum funcionario selecionado'),
        subtitle: Text(
          employee == null
              ? 'Selecione um funcionario para iniciar o atendimento'
              : 'Codigo ${employee!.codigo}',
        ),
        trailing: FilledButton.icon(
          onPressed: enabled ? onSelectEmployee : null,
          icon: const Icon(Icons.person_search_outlined),
          label: const Text('Selecionar'),
        ),
      ),
    );
  }
}

class _ConnectionPanel extends StatelessWidget {
  const _ConnectionPanel({required this.config, required this.onConfigure});

  final AppConfig config;
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  config.isServerConfigured
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined,
                  color: config.isServerConfigured
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    config.isServerConfigured
                        ? 'Servidor configurado'
                        : 'Configure o servidor',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: onConfigure,
                  icon: const Icon(Icons.tune),
                  label: const Text('Configurar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(config.baseUrl, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(
              config.phpContext,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({
    required this.configured,
    required this.hasEmployee,
    required this.hasCommand,
    required this.onSelectEmployee,
    required this.onSelectCommand,
    required this.onOpenItems,
    required this.onOpenKitchen,
  });

  final bool configured;
  final bool hasEmployee;
  final bool hasCommand;
  final VoidCallback onSelectEmployee;
  final VoidCallback onSelectCommand;
  final VoidCallback onOpenItems;
  final VoidCallback onOpenKitchen;

  @override
  Widget build(BuildContext context) {
    final modules = [
      const _ModuleAction(
        icon: Icons.badge_outlined,
        title: 'Funcionario',
        subtitle: 'Selecionar operador',
      ),
      const _ModuleAction(
        icon: Icons.receipt_long_outlined,
        title: 'Comandas',
        subtitle: 'Selecionar comanda',
      ),
      const _ModuleAction(
        icon: Icons.format_list_bulleted_outlined,
        title: 'Itens',
        subtitle: 'Ver itens',
      ),
      const _ModuleAction(
        icon: Icons.room_service_outlined,
        title: 'Cozinha',
        subtitle: 'Preparo',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: crossAxisCount == 2 ? 1.15 : 1.25,
          ),
          itemBuilder: (context, index) {
            return _ModuleTile(
              action: modules[index],
              enabled: switch (index) {
                0 => configured,
                1 => configured && hasEmployee,
                2 => configured && hasEmployee && hasCommand,
                3 => configured && hasEmployee,
                _ => false,
              },
              onTap: switch (index) {
                0 => onSelectEmployee,
                1 => onSelectCommand,
                2 => onOpenItems,
                3 => onOpenKitchen,
                _ => null,
              },
            );
          },
        );
      },
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.action,
    required this.enabled,
    required this.onTap,
  });

  final _ModuleAction action;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                action.icon,
                color: enabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              const Spacer(),
              Text(action.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                action.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleAction {
  const _ModuleAction({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
