import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/config/app_config_store.dart';
import '../../core/models/empresa_config.dart';
import '../../core/models/funcionario.dart';
import '../company/company_repository.dart';
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
  late Future<_HomeData> _homeFuture;
  Funcionario? _selectedEmployee;
  CommandSelection? _selectedCommand;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHomeData();
  }

  void _reloadConfig() {
    setState(() {
      _homeFuture = _loadHomeData();
    });
  }

  Future<_HomeData> _loadHomeData() async {
    final config = await widget.configStore.load();
    if (!config.isServerConfigured) {
      return _HomeData(config: config, companyConfig: EmpresaConfig.defaults());
    }

    try {
      final companyConfig = await CompanyRepository(
        config: config,
      ).fetchCompanyConfig();
      return _HomeData(config: config, companyConfig: companyConfig);
    } catch (error) {
      return _HomeData(
        config: config,
        companyConfig: EmpresaConfig.defaults(),
        companyError: error.toString(),
      );
    }
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

  Future<void> _selectCommand(
    AppConfig config,
    EmpresaConfig companyConfig,
  ) async {
    final employee = _selectedEmployee;
    if (employee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um funcionario primeiro.')),
      );
      return;
    }

    final command = await Navigator.of(context).push<CommandSelection>(
      MaterialPageRoute(
        builder: (_) => CommandSelectionPage(
          config: config,
          employee: employee,
          companyConfig: companyConfig,
        ),
      ),
    );

    if (command != null && mounted) {
      setState(() {
        _selectedCommand = command.codigoComanda > 0 ? command : null;
      });
    }
  }

  Future<void> _openItems(AppConfig config, EmpresaConfig companyConfig) async {
    final employee = _selectedEmployee;
    var command = _selectedCommand;

    if (employee == null || command == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione funcionario e comanda.')),
      );
      return;
    }

    command = await _applyCommandRequirements(command, companyConfig);
    if (command == null || !mounted) {
      return;
    }

    setState(() {
      _selectedCommand = command;
    });

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ItemListPage(
          config: config,
          employee: employee,
          command: command!,
          companyConfig: companyConfig,
        ),
      ),
    );
  }

  Future<void> _openKitchen(
    AppConfig config,
    EmpresaConfig companyConfig,
  ) async {
    final employee = _selectedEmployee;

    if (employee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um funcionario primeiro.')),
      );
      return;
    }

    if (!companyConfig.controlaCozinha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modulo de cozinha desabilitado.')),
      );
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => KitchenPage(config: config, employee: employee),
      ),
    );
  }

  Future<CommandSelection?> _applyCommandRequirements(
    CommandSelection command,
    EmpresaConfig companyConfig,
  ) async {
    var resolved = command;

    if (companyConfig.controlaMesa && resolved.codigoMesa <= 0) {
      final mesa = await _askRequiredNumber(
        title: 'Mesa da comanda',
        label: 'Mesa',
        icon: Icons.table_restaurant_outlined,
      );

      if (mesa == null) {
        return null;
      }

      resolved = resolved.copyWith(codigoMesa: mesa);
    }

    if (companyConfig.controlaTag && resolved.codigoTag <= 0) {
      final tag = await _askRequiredNumber(
        title: 'Tag da comanda',
        label: 'Tag',
        icon: Icons.sell_outlined,
      );

      if (tag == null) {
        return null;
      }

      resolved = resolved.copyWith(codigoTag: tag);
    }

    return resolved;
  }

  Future<int?> _askRequiredNumber({
    required String title,
    required String label,
    required IconData icon,
  }) {
    return showDialog<int>(
      context: context,
      builder: (_) =>
          _RequiredNumberDialog(title: title, label: label, icon: icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeData>(
      future: _homeFuture,
      builder: (context, snapshot) {
        final homeData =
            snapshot.data ??
            _HomeData(
              config: AppConfig.defaults(),
              companyConfig: EmpresaConfig.defaults(),
            );
        final config = homeData.config;

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
                  companyConfig: homeData.companyConfig,
                  companyError: homeData.companyError,
                  selectedEmployee: _selectedEmployee,
                  selectedCommand: _selectedCommand,
                  onConfigure: () => _openSettings(config),
                  onSelectEmployee: () => _selectEmployee(config),
                  onSelectCommand: () =>
                      _selectCommand(config, homeData.companyConfig),
                  onOpenItems: () => _openItems(config, homeData.companyConfig),
                  onOpenKitchen: () =>
                      _openKitchen(config, homeData.companyConfig),
                ),
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.config,
    required this.companyConfig,
    required this.companyError,
    required this.selectedEmployee,
    required this.selectedCommand,
    required this.onConfigure,
    required this.onSelectEmployee,
    required this.onSelectCommand,
    required this.onOpenItems,
    required this.onOpenKitchen,
  });

  final AppConfig config;
  final EmpresaConfig companyConfig;
  final String? companyError;
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
          if (companyError != null) ...[
            const SizedBox(height: 16),
            _CompanyRulesError(message: companyError!),
          ] else if (config.isServerConfigured) ...[
            const SizedBox(height: 16),
            _CompanyRulesPanel(companyConfig: companyConfig),
          ],
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
            kitchenEnabled: companyConfig.controlaCozinha,
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

class _CompanyRulesPanel extends StatelessWidget {
  const _CompanyRulesPanel({required this.companyConfig});

  final EmpresaConfig companyConfig;

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
                Icon(Icons.rule_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Regras da empresa', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _RuleChip(
                  icon: Icons.table_restaurant_outlined,
                  label: 'Mesa',
                  enabled: companyConfig.controlaMesa,
                ),
                _RuleChip(
                  icon: Icons.sell_outlined,
                  label: 'Tag',
                  enabled: companyConfig.controlaTag,
                ),
                _RuleChip(
                  icon: Icons.room_service_outlined,
                  label: 'Cozinha',
                  enabled: companyConfig.controlaCozinha,
                ),
                _RuleChip(
                  icon: Icons.swap_horiz_outlined,
                  label: switch (companyConfig.controlaTroca) {
                    TrocaComandaPolicy.exigeSenha => 'Troca com senha',
                    TrocaComandaPolicy.desabilitada => 'Troca bloqueada',
                    TrocaComandaPolicy.livre => 'Troca livre',
                  },
                  enabled:
                      companyConfig.controlaTroca !=
                      TrocaComandaPolicy.desabilitada,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleChip extends StatelessWidget {
  const _RuleChip({
    required this.icon,
    required this.label,
    required this.enabled,
  });

  final IconData icon;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(enabled ? label : '$label off'),
      backgroundColor: enabled
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      side: BorderSide(color: theme.colorScheme.outlineVariant),
    );
  }
}

class _CompanyRulesError extends StatelessWidget {
  const _CompanyRulesError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.warning_amber_outlined,
          color: theme.colorScheme.error,
        ),
        title: const Text('Regras da empresa nao carregadas'),
        subtitle: Text(message),
      ),
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({
    required this.configured,
    required this.hasEmployee,
    required this.hasCommand,
    required this.kitchenEnabled,
    required this.onSelectEmployee,
    required this.onSelectCommand,
    required this.onOpenItems,
    required this.onOpenKitchen,
  });

  final bool configured;
  final bool hasEmployee;
  final bool hasCommand;
  final bool kitchenEnabled;
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
                3 => configured && hasEmployee && kitchenEnabled,
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

class _RequiredNumberDialog extends StatefulWidget {
  const _RequiredNumberDialog({
    required this.title,
    required this.label,
    required this.icon,
  });

  final String title;
  final String label;
  final IconData icon;

  @override
  State<_RequiredNumberDialog> createState() => _RequiredNumberDialogState();
}

class _RequiredNumberDialogState extends State<_RequiredNumberDialog> {
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
        _error = 'Informe um valor valido';
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

class _HomeData {
  const _HomeData({
    required this.config,
    required this.companyConfig,
    this.companyError,
  });

  final AppConfig config;
  final EmpresaConfig companyConfig;
  final String? companyError;
}
