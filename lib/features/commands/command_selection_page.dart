import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/models/empresa_config.dart';
import '../../core/models/comanda.dart';
import '../../core/models/funcionario.dart';
import '../../core/utils/command_check_digit.dart';
import '../../core/widgets/operational_keyboard.dart';
import '../employees/employee_repository.dart';
import 'command_repository.dart';
import 'command_selection.dart';

class CommandSelectionPage extends StatefulWidget {
  const CommandSelectionPage({
    super.key,
    required this.config,
    required this.employee,
    required this.companyConfig,
    CommandRepository? repository,
  }) : _repository = repository;

  final AppConfig config;
  final Funcionario employee;
  final EmpresaConfig companyConfig;
  final CommandRepository? _repository;

  @override
  State<CommandSelectionPage> createState() => _CommandSelectionPageState();
}

class _CommandSelectionPageState extends State<CommandSelectionPage> {
  final _commandController = TextEditingController();
  late Future<List<Comanda>> _commandsFuture;
  bool _consulting = false;
  bool _busy = false;

  CommandRepository get _repository {
    return widget._repository ?? CommandRepository(config: widget.config);
  }

  @override
  void initState() {
    super.initState();
    _commandsFuture = _repository.fetchCommands();
  }

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _commandsFuture = _repository.fetchCommands();
    });
  }

  Future<void> _consultTypedCommand() async {
    final codigo = parseCommandCode(
      _commandController.text,
      checkDigitEnabled: widget.config.commandCheckDigitEnabled,
    );
    if (codigo == null || codigo <= 0) {
      _showMessage('Informe uma comanda valida.');
      return;
    }

    await _selectByCode(codigo);
  }

  Future<void> _selectCommand(Comanda command) async {
    await _selectByCode(command.codigoComanda);
  }

  Future<void> _selectByCode(int codigoComanda) async {
    setState(() {
      _consulting = true;
    });

    try {
      final selection = await _repository.lookupCommand(codigoComanda);
      if (!mounted) {
        return;
      }

      if (selection.estaBloqueada) {
        _showMessage('Comanda bloqueada. Operacao nao pode ser realizada.');
        return;
      }

      Navigator.of(context).pop(selection);
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _consulting = false;
        });
      }
    }
  }

  Future<void> _changeMesa(Comanda command) async {
    if (command.estaBloqueada || _busy) {
      _showMessage('Comanda bloqueada. Operacao nao pode ser realizada.');
      return;
    }

    final novaMesa = await _askNumber(
      title: 'informe a nova mesa',
      initialValue: command.codigoMesa > 0 ? command.codigoMesa.toString() : '',
      color: const Color(0xFF35B779),
      invalidMessage: 'Informe uma mesa valida',
      allowZero: true,
    );

    if (novaMesa == null || !mounted) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await _repository.updateMesa(
        employee: widget.employee,
        codigoComanda: command.codigoComanda,
        novaMesa: novaMesa,
      );

      if (!mounted) {
        return;
      }

      _showMessage('Mesa alterada');
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

  Future<void> _changeCommand(Comanda command) async {
    if (command.estaBloqueada || _busy) {
      _showMessage('Comanda bloqueada. Operacao nao pode ser realizada.');
      return;
    }

    final authorizedEmployee = await _authorizeTrade();
    if (authorizedEmployee == null || !mounted) {
      return;
    }

    final novaComanda = await _askNumber(
      title: 'informe a nova comanda',
      color: const Color(0xFF35B779),
      invalidMessage: 'Informe uma comanda valida',
    );

    if (novaComanda == null || !mounted) {
      return;
    }

    if (novaComanda == command.codigoComanda) {
      _showMessage('A nova comanda deve ser diferente da atual.');
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await _repository.changeCommand(
        employee: authorizedEmployee,
        codigoComanda: command.codigoComanda,
        novaComanda: novaComanda,
      );

      if (!mounted) {
        return;
      }

      _showMessage('Comanda alterada');
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

  Future<Funcionario?> _authorizeTrade() async {
    switch (widget.companyConfig.controlaTroca) {
      case TrocaComandaPolicy.desabilitada:
        _showMessage('Operacao desabilitada. Nao e possivel fazer a troca.');
        return null;
      case TrocaComandaPolicy.livre:
        return widget.employee;
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
            _showMessage('Senha invalida');
            return null;
          }

          return authorization;
        } catch (error) {
          if (mounted) {
            _showMessage(error.toString());
          }
          return null;
        } finally {
          if (mounted) {
            setState(() {
              _busy = false;
            });
          }
        }
    }
  }

  Future<void> _deleteCommand(Comanda command) async {
    if (command.estaBloqueada || _busy) {
      _showMessage('Comanda bloqueada. Operacao nao pode ser realizada.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir comanda'),
        content: Text('Excluir a comanda ${command.codigoComanda}?'),
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
          _showMessage('Senha invalida');
          return;
        }

        authorizedEmployee = authorization;
      } catch (error) {
        if (mounted) {
          _showMessage(error.toString());
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
      await _repository.deleteCommand(
        employee: authorizedEmployee,
        codigoComanda: command.codigoComanda,
      );

      if (!mounted) {
        return;
      }

      _showMessage('Comanda excluida');
      Navigator.of(context).pop(
        const CommandSelection(
          codigoComanda: 0,
          codigoMesa: 0,
          codigoTag: 0,
          bloqueio: 0,
        ),
      );
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

  Future<int?> _askNumber({
    required String title,
    required Color color,
    required String invalidMessage,
    String initialValue = '',
    bool allowZero = false,
  }) async {
    if (widget.config.physicalKeyboardEnabled) {
      return showDialog<int>(
        context: context,
        builder: (_) => _NumberDialog(
          title: title,
          label: title,
          icon: Icons.receipt_long_outlined,
          invalidMessage: invalidMessage,
          initialValue: initialValue,
          allowZero: allowZero,
        ),
      );
    }

    final result = await showOperationalKeyboard(
      context: context,
      title: title,
      initialValue: initialValue,
      mode: OperationalKeyboardMode.numeric,
      color: color,
    );
    if (result == null || result.action == OperationalKeyboardAction.back) {
      return null;
    }

    final value = int.tryParse(result.value);
    if (value == null || value < (allowZero ? 0 : 1)) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comandas'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CommandInputCard(
              controller: _commandController,
              employee: widget.employee,
              useSystemKeyboard: widget.config.physicalKeyboardEnabled,
              consulting: _consulting,
              onConsult: _consultTypedCommand,
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Comanda>>(
              future: _commandsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return _CommandError(
                    message: snapshot.error.toString(),
                    onRetry: _reload,
                  );
                }

                final commands = snapshot.data ?? const <Comanda>[];
                if (commands.isEmpty) {
                  return _CommandError(
                    message: 'Nenhuma comanda aberta encontrada.',
                    onRetry: _reload,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comandas abertas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...commands.map(
                      (command) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _CommandTile(
                          command: command,
                          enabled: !_consulting && !_busy,
                          onTap: _consulting || _busy
                              ? null
                              : () => _selectCommand(command),
                          onChangeCommand: () => _changeCommand(command),
                          onChangeMesa: () => _changeMesa(command),
                          onDelete: () => _deleteCommand(command),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberDialog extends StatefulWidget {
  const _NumberDialog({
    required this.title,
    required this.label,
    required this.icon,
    required this.invalidMessage,
    this.initialValue = '',
    this.allowZero = false,
  });

  final String title;
  final String label;
  final IconData icon;
  final String invalidMessage;
  final String initialValue;
  final bool allowZero;

  @override
  State<_NumberDialog> createState() => _NumberDialogState();
}

class _NumberDialogState extends State<_NumberDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value < (widget.allowZero ? 0 : 1)) {
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

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
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

class _CommandInputCard extends StatelessWidget {
  const _CommandInputCard({
    required this.controller,
    required this.employee,
    required this.useSystemKeyboard,
    required this.consulting,
    required this.onConsult,
  });

  final TextEditingController controller;
  final Funcionario employee;
  final bool useSystemKeyboard;
  final bool consulting;
  final VoidCallback onConsult;

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
                Icon(Icons.badge_outlined, color: theme.colorScheme.primary),
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
              enabled: !consulting,
              useSystemKeyboard: useSystemKeyboard,
              title: 'informe a comanda',
              labelText: 'Codigo da comanda',
              prefixIcon: Icons.receipt_long_outlined,
              mode: OperationalKeyboardMode.numeric,
              color: const Color(0xFF35B779),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              showListAction: true,
              onConfirm: onConsult,
              onList: onConsult,
            ),
            if (useSystemKeyboard) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: consulting ? null : onConsult,
                  icon: consulting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search_outlined),
                  label: const Text('Consultar comanda'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommandTile extends StatelessWidget {
  const _CommandTile({
    required this.command,
    required this.enabled,
    required this.onTap,
    required this.onChangeCommand,
    required this.onChangeMesa,
    required this.onDelete,
  });

  final Comanda command;
  final bool enabled;
  final VoidCallback? onTap;
  final VoidCallback onChangeCommand;
  final VoidCallback onChangeMesa;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _CommandCodePill(
                code: command.codigoComanda.toString(),
                locked: command.estaBloqueada,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comanda ${command.codigoComanda}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _badges
                          .map((badge) => _CommandBadge(label: badge))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (command.estaBloqueada)
                Icon(Icons.lock_outline, color: theme.colorScheme.error)
              else
                Icon(Icons.chevron_right, color: theme.colorScheme.primary),
              PopupMenuButton<_CommandAction>(
                enabled: enabled && !command.estaBloqueada,
                onSelected: (action) {
                  switch (action) {
                    case _CommandAction.changeCommand:
                      onChangeCommand();
                    case _CommandAction.changeMesa:
                      onChangeMesa();
                    case _CommandAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _CommandAction.changeCommand,
                    child: ListTile(
                      leading: Icon(Icons.swap_horiz_outlined),
                      title: Text('Trocar comanda'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _CommandAction.changeMesa,
                    child: ListTile(
                      leading: Icon(Icons.table_restaurant_outlined),
                      title: Text('Trocar mesa'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _CommandAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Excluir comanda'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> get _badges {
    return <String>[
      if (command.codigoMesa > 0) 'Mesa ${command.codigoMesa}',
      if (command.codigoTag > 0) 'Tag ${command.codigoTag}',
      if (command.nomeFuncionario.trim().isNotEmpty) command.nomeFuncionario,
      'R\$ ${command.valorTotal.toStringAsFixed(2)}',
    ];
  }
}

enum _CommandAction { changeCommand, changeMesa, delete }

class _CommandBadge extends StatelessWidget {
  const _CommandBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(label, style: theme.textTheme.bodySmall),
      ),
    );
  }
}

class _CommandCodePill extends StatelessWidget {
  const _CommandCodePill({required this.code, required this.locked});

  final String code;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 72,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: locked
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.primaryContainer,
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
              color: locked
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _CommandError extends StatelessWidget {
  const _CommandError({required this.message, required this.onRetry});

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
              Icons.receipt_long_outlined,
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
