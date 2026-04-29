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
  late Future<List<Funcionario>> _employeesFuture;

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

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: employees.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final employee = employees[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(employee.codigo.toString()),
                    ),
                    title: Text(employee.nome),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pop(employee),
                  ),
                );
              },
            );
          },
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
