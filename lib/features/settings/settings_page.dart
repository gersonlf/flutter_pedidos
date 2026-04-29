import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/config/app_config_store.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.initialConfig,
    required this.configStore,
  });

  final AppConfig initialConfig;
  final AppConfigStore configStore;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serverController;
  late final TextEditingController _portController;
  late final TextEditingController _contextController;

  late AppProtocol _protocol;
  late bool _physicalKeyboardEnabled;
  late bool _commandCheckDigitEnabled;
  late bool _requirePasswordToDelete;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final config = widget.initialConfig;
    _serverController = TextEditingController(text: config.server);
    _portController = TextEditingController(text: config.port.toString());
    _contextController = TextEditingController(text: config.context);
    _protocol = config.protocol;
    _physicalKeyboardEnabled = config.physicalKeyboardEnabled;
    _commandCheckDigitEnabled = config.commandCheckDigitEnabled;
    _requirePasswordToDelete = config.requirePasswordToDelete;
  }

  @override
  void dispose() {
    _serverController.dispose();
    _portController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final config = AppConfig(
      server: _serverController.text.trim(),
      port: int.parse(_portController.text.trim()),
      context: _contextController.text.trim(),
      protocol: _protocol,
      physicalKeyboardEnabled: _physicalKeyboardEnabled,
      commandCheckDigitEnabled: _commandCheckDigitEnabled,
      requirePasswordToDelete: _requirePasswordToDelete,
    );

    await widget.configStore.save(config);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Configuracao salva')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuracao')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _serverController,
                decoration: const InputDecoration(
                  labelText: 'Servidor',
                  prefixIcon: Icon(Icons.dns_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o servidor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Porta',
                  prefixIcon: Icon(Icons.numbers_outlined),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final port = int.tryParse(value?.trim() ?? '');
                  if (port == null || port <= 0 || port > 65535) {
                    return 'Informe uma porta valida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contextController,
                decoration: const InputDecoration(
                  labelText: 'Contexto',
                  prefixIcon: Icon(Icons.folder_outlined),
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o contexto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SegmentedButton<AppProtocol>(
                segments: const [
                  ButtonSegment(
                    value: AppProtocol.http,
                    icon: Icon(Icons.public_outlined),
                    label: Text('HTTP'),
                  ),
                  ButtonSegment(
                    value: AppProtocol.https,
                    icon: Icon(Icons.lock_outline),
                    label: Text('HTTPS'),
                  ),
                ],
                selected: {_protocol},
                onSelectionChanged: (value) {
                  setState(() {
                    _protocol = value.single;
                  });
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _physicalKeyboardEnabled,
                      onChanged: (value) {
                        setState(() {
                          _physicalKeyboardEnabled = value;
                        });
                      },
                      secondary: const Icon(Icons.keyboard_outlined),
                      title: const Text('Teclado fisico'),
                    ),
                    SwitchListTile(
                      value: _commandCheckDigitEnabled,
                      onChanged: (value) {
                        setState(() {
                          _commandCheckDigitEnabled = value;
                        });
                      },
                      secondary: const Icon(Icons.pin_outlined),
                      title: const Text('Digito verificador da comanda'),
                    ),
                    SwitchListTile(
                      value: _requirePasswordToDelete,
                      onChanged: (value) {
                        setState(() {
                          _requirePasswordToDelete = value;
                        });
                      },
                      secondary: const Icon(Icons.password_outlined),
                      title: const Text('Senha para excluir'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
