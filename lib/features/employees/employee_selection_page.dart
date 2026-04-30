import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/models/funcionario.dart';
import 'employee_repository.dart';

class EmployeeSelectionPage extends StatefulWidget {
  const EmployeeSelectionPage({
    super.key,
    required this.config,
    EmployeeRepository? repository,
  }) : _repository = repository;

  final AppConfig config;
  final EmployeeRepository? _repository;

  @override
  State<EmployeeSelectionPage> createState() => _EmployeeSelectionPageState();
}

class _EmployeeSelectionPageState extends State<EmployeeSelectionPage> {
  final _employeeController = TextEditingController();
  late Future<List<Funcionario>> _employeesFuture;
  bool _consulting = false;

  EmployeeRepository get _repository {
    return widget._repository ?? EmployeeRepository(config: widget.config);
  }

  @override
  void initState() {
    super.initState();
    _employeesFuture = _repository.fetchEmployees();
  }

  void _reload() {
    setState(() {
      _employeesFuture = _repository.fetchEmployees();
    });
  }

  @override
  void dispose() {
    _employeeController.dispose();
    super.dispose();
  }

  Future<void> _consultTypedEmployee() async {
    final codigo = int.tryParse(_employeeController.text.trim());
    if (codigo == null || codigo <= 0) {
      _showMessage('Informe um funcionario valido.');
      return;
    }

    setState(() {
      _consulting = true;
    });

    try {
      final employees = await _employeesFuture;
      final matches = employees.where((employee) => employee.codigo == codigo);

      if (!mounted) {
        return;
      }

      if (matches.isEmpty) {
        _showMessage('Funcionario nao encontrado.');
        return;
      }

      Navigator.of(context).pop(matches.first);
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funcionario'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Funcionario>>(
          future: _employeesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _EmployeeError(
                message: snapshot.error.toString(),
                onRetry: _reload,
              );
            }

            final employees = snapshot.data ?? const <Funcionario>[];
            if (employees.isEmpty) {
              return _EmployeeError(
                message: 'Nenhum funcionario encontrado.',
                onRetry: _reload,
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _EmployeeInputCard(
                  controller: _employeeController,
                  consulting: _consulting,
                  onConsult: _consultTypedEmployee,
                ),
                const SizedBox(height: 16),
                ...employees.map(
                  (employee) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: ListTile(
                        leading: _CodePill(code: employee.codigo.toString()),
                        title: Text(employee.nome),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _consulting
                            ? null
                            : () => Navigator.of(context).pop(employee),
                      ),
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

class _EmployeeInputCard extends StatelessWidget {
  const _EmployeeInputCard({
    required this.controller,
    required this.consulting,
    required this.onConsult,
  });

  final TextEditingController controller;
  final bool consulting;
  final VoidCallback onConsult;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final field = TextField(
              controller: controller,
              autofocus: true,
              enabled: !consulting,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onConsult(),
              decoration: const InputDecoration(
                labelText: 'Codigo do funcionario',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            );
            final button = FilledButton.icon(
              onPressed: consulting ? null : onConsult,
              icon: consulting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search_outlined),
              label: const Text('Consultar funcionario'),
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
    );
  }
}

class _CodePill extends StatelessWidget {
  const _CodePill({required this.code});

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

class _EmployeeError extends StatelessWidget {
  const _EmployeeError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.badge_outlined,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
