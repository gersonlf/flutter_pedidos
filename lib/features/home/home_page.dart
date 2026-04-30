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
import '../products/product_search_page.dart';
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
    } catch (_) {
      return _HomeData(config: config, companyConfig: EmpresaConfig.defaults());
    }
  }

  Future<void> _openSettings(AppConfig config) async {
    if (config.hasSettingsPassword) {
      final authorized = await _askSettingsPassword(config);
      if (!authorized || !mounted) {
        return;
      }
    }

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

  Future<bool> _askSettingsPassword(AppConfig config) async {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _SettingsPasswordDialog(),
    );

    if (password == null) {
      return false;
    }

    final authorized = password == config.settingsPassword;
    if (!authorized && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Senha incorreta.')));
    }

    return authorized;
  }

  Future<void> _selectEmployee(
    AppConfig config,
    EmpresaConfig companyConfig,
  ) async {
    final employee = await Navigator.of(context).push<Funcionario>(
      MaterialPageRoute(builder: (_) => EmployeeSelectionPage(config: config)),
    );

    if (employee != null && mounted) {
      setState(() {
        _selectedEmployee = employee;
        _selectedCommand = null;
      });

      await _selectCommand(config, companyConfig);
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

      if (command.codigoComanda > 0) {
        await _openItems(config, companyConfig);
      }
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

  Future<void> _openProductConsultation(AppConfig config) async {
    if (!config.isServerConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configure o servidor primeiro.')),
      );
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            ProductSearchPage(config: config, selectionEnabled: false),
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
                  selectedEmployee: _selectedEmployee,
                  selectedCommand: _selectedCommand,
                  onConfigure: () => _openSettings(config),
                  onSelectEmployee: () =>
                      _selectEmployee(config, homeData.companyConfig),
                  onSelectCommand: () =>
                      _selectCommand(config, homeData.companyConfig),
                  onOpenItems: () => _openItems(config, homeData.companyConfig),
                  onOpenProductConsultation: () =>
                      _openProductConsultation(config),
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
    required this.selectedEmployee,
    required this.selectedCommand,
    required this.onConfigure,
    required this.onSelectEmployee,
    required this.onSelectCommand,
    required this.onOpenItems,
    required this.onOpenProductConsultation,
    required this.onOpenKitchen,
  });

  final AppConfig config;
  final EmpresaConfig companyConfig;
  final Funcionario? selectedEmployee;
  final CommandSelection? selectedCommand;
  final VoidCallback onConfigure;
  final VoidCallback onSelectEmployee;
  final VoidCallback onSelectCommand;
  final VoidCallback onOpenItems;
  final VoidCallback onOpenProductConsultation;
  final VoidCallback onOpenKitchen;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!config.isServerConfigured) ...[
            _ConnectionPanel(config: config, onConfigure: onConfigure),
            const SizedBox(height: 16),
          ],
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
          _ItemsPanel(
            command: selectedCommand,
            enabled:
                config.isServerConfigured &&
                selectedEmployee != null &&
                selectedCommand != null,
            onOpenItems: onOpenItems,
          ),
          const SizedBox(height: 16),
          _ProductConsultationPanel(
            enabled: config.isServerConfigured,
            onOpenProductConsultation: onOpenProductConsultation,
          ),
          const SizedBox(height: 16),
          _KitchenPanel(
            configured: config.isServerConfigured,
            hasEmployee: selectedEmployee != null,
            kitchenEnabled: companyConfig.controlaCozinha,
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
      color: theme.colorScheme.tertiaryContainer,
      child: ListTile(
        leading: Icon(
          command == null
              ? Icons.receipt_long_outlined
              : Icons.assignment_turned_in_outlined,
          color: theme.colorScheme.onTertiaryContainer,
        ),
        title: Text(
          command == null ? 'Consultar comandas' : 'Selecionar outra comanda',
        ),
        trailing: FilledButton.icon(
          onPressed: enabled ? onSelectCommand : null,
          icon: const Icon(Icons.search_outlined),
          label: const Text('Selecionar'),
        ),
      ),
    );
  }
}

class _ItemsPanel extends StatelessWidget {
  const _ItemsPanel({
    required this.command,
    required this.enabled,
    required this.onOpenItems,
  });

  final CommandSelection? command;
  final bool enabled;
  final VoidCallback onOpenItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: Icon(
          Icons.format_list_bulleted_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(command?.resumo ?? 'Itens'),
        subtitle: Text(
          command == null
              ? 'Selecione uma comanda antes de lancar itens'
              : command!.estaBloqueada
              ? 'Comanda bloqueada'
              : 'Abrir itens da comanda selecionada',
        ),
        trailing: FilledButton.icon(
          onPressed: enabled ? onOpenItems : null,
          icon: const Icon(Icons.open_in_new_outlined),
          label: const Text('Abrir'),
        ),
      ),
    );
  }
}

class _ProductConsultationPanel extends StatelessWidget {
  const _ProductConsultationPanel({
    required this.enabled,
    required this.onOpenProductConsultation,
  });

  final bool enabled;
  final VoidCallback onOpenProductConsultation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.errorContainer,
      child: ListTile(
        leading: Icon(
          Icons.inventory_2_outlined,
          color: theme.colorScheme.onErrorContainer,
        ),
        title: const Text('Pesquisar preco, codigo e dados do produto'),
        trailing: FilledButton.icon(
          onPressed: enabled ? onOpenProductConsultation : null,
          icon: const Icon(Icons.search_outlined),
          label: const Text('Consultar'),
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
      color: theme.colorScheme.primaryContainer,
      child: ListTile(
        leading: Icon(
          employee == null ? Icons.badge_outlined : Icons.verified_user,
          color: theme.colorScheme.onPrimaryContainer,
        ),
        title: Text(
          employee?.nome ??
              'Selecione um funcionario para iniciar o atendimento',
        ),
        subtitle: employee == null ? null : Text('Codigo ${employee!.codigo}'),
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

class _KitchenPanel extends StatelessWidget {
  const _KitchenPanel({
    required this.configured,
    required this.hasEmployee,
    required this.kitchenEnabled,
    required this.onOpenKitchen,
  });

  final bool configured;
  final bool hasEmployee;
  final bool kitchenEnabled;
  final VoidCallback onOpenKitchen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = configured && hasEmployee && kitchenEnabled;

    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: ListTile(
        leading: Icon(
          Icons.room_service_outlined,
          color: theme.colorScheme.onSecondaryContainer,
        ),
        title: Text(
          !configured
              ? 'Configure o servidor antes de acessar'
              : !hasEmployee
              ? 'Selecione um funcionario primeiro'
              : kitchenEnabled
              ? 'Pedidos prontos e entregues'
              : 'Modulo desabilitado',
        ),
        trailing: FilledButton.icon(
          onPressed: enabled ? onOpenKitchen : null,
          icon: const Icon(Icons.open_in_new_outlined),
          label: const Text('Abrir'),
        ),
      ),
    );
  }
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

class _SettingsPasswordDialog extends StatefulWidget {
  const _SettingsPasswordDialog();

  @override
  State<_SettingsPasswordDialog> createState() =>
      _SettingsPasswordDialogState();
}

class _SettingsPasswordDialogState extends State<_SettingsPasswordDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final password = _controller.text.trim();
    if (password.isEmpty) {
      setState(() {
        _error = 'Informe a senha';
      });
      return;
    }

    Navigator.of(context).pop(password);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Senha da configuracao'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        obscureText: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _confirm(),
        decoration: InputDecoration(
          labelText: 'Senha',
          prefixIcon: const Icon(Icons.lock_outline),
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirm, child: const Text('Entrar')),
      ],
    );
  }
}

class _HomeData {
  const _HomeData({required this.config, required this.companyConfig});

  final AppConfig config;
  final EmpresaConfig companyConfig;
}
