import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/models/funcionario.dart';
import '../../core/widgets/operational_keyboard.dart';
import 'employee_repository.dart';

const _employeeColor = Color(0xFFFF9A7B);

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
        backgroundColor: _employeeColor,
        foregroundColor: Colors.white,
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

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _EmployeeInputCard(
                    controller: _employeeController,
                    useSystemKeyboard: widget.config.physicalKeyboardEnabled,
                    consulting: _consulting,
                    onConsult: _consultTypedEmployee,
                    previewLoader: (value) =>
                        _previewEmployee(value, employees),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: _CodePill(
                              code: employee.codigo.toString(),
                            ),
                            title: Text(employee.nome),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _consulting
                                ? null
                                : () => Navigator.of(context).pop(employee),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<String?> _previewEmployee(
    String value,
    List<Funcionario> employees,
  ) async {
    final query = value.trim();
    final codigo = int.tryParse(query);
    if (query.isEmpty || codigo == null || codigo <= 0) {
      return null;
    }

    final exactMatches = employees.where(
      (employee) => employee.codigo == codigo,
    );
    final matches = exactMatches.isNotEmpty
        ? exactMatches
        : employees.where(
            (employee) => employee.codigo.toString().startsWith(query),
          );
    if (matches.isEmpty) {
      return null;
    }

    final employee = matches.first;
    return '${employee.codigo} - ${employee.nome}';
  }
}

class _EmployeeInputCard extends StatelessWidget {
  const _EmployeeInputCard({
    required this.controller,
    required this.useSystemKeyboard,
    required this.consulting,
    required this.onConsult,
    required this.previewLoader,
  });

  final TextEditingController controller;
  final bool useSystemKeyboard;
  final bool consulting;
  final VoidCallback onConsult;
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
              enabled: !consulting,
              useSystemKeyboard: useSystemKeyboard,
              title: 'informe o funcionario',
              labelText: 'Codigo do funcionario',
              prefixIcon: Icons.badge_outlined,
              mode: OperationalKeyboardMode.numeric,
              color: _employeeColor,
              clearOnOpen: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              showListAction: true,
              onConfirm: onConsult,
              previewLoader: previewLoader,
            );
            final button = useSystemKeyboard
                ? FilledButton.icon(
                    onPressed: consulting ? null : onConsult,
                    icon: consulting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search_outlined),
                    label: const Text('Consultar funcionario'),
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
        color: _employeeColor,
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
