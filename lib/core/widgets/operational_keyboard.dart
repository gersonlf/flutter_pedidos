import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum OperationalKeyboardMode { numeric, alpha }

enum OperationalKeyboardAction { confirm, list, back }

typedef OperationalKeyboardPreviewLoader =
    Future<String?> Function(String value);

class OperationalKeyboardResult {
  const OperationalKeyboardResult({required this.action, required this.value});

  final OperationalKeyboardAction action;
  final String value;
}

Future<OperationalKeyboardResult?> showOperationalKeyboard({
  required BuildContext context,
  required String title,
  required String initialValue,
  required OperationalKeyboardMode mode,
  required Color color,
  bool allowDecimal = false,
  bool obscure = false,
  bool showListAction = false,
  bool allowAlphaSwitch = false,
  bool allowObservationSwitch = false,
  bool replaceInitialValueOnFirstInput = false,
  OperationalKeyboardPreviewLoader? previewLoader,
}) {
  return Navigator.of(context).push<OperationalKeyboardResult>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => OperationalKeyboardPage(
        title: title,
        initialValue: initialValue,
        mode: mode,
        color: color,
        allowDecimal: allowDecimal,
        obscure: obscure,
        showListAction: showListAction,
        allowAlphaSwitch: allowAlphaSwitch,
        allowObservationSwitch: allowObservationSwitch,
        replaceInitialValueOnFirstInput: replaceInitialValueOnFirstInput,
        previewLoader: previewLoader,
      ),
    ),
  );
}

class OperationalKeyboardTextField extends StatelessWidget {
  const OperationalKeyboardTextField({
    super.key,
    required this.controller,
    required this.title,
    required this.labelText,
    required this.prefixIcon,
    required this.useSystemKeyboard,
    required this.mode,
    required this.color,
    this.enabled = true,
    this.allowDecimal = false,
    this.obscure = false,
    this.showListAction = false,
    this.allowAlphaSwitch = false,
    this.allowObservationSwitch = false,
    this.clearOnOpen = false,
    this.textInputAction = TextInputAction.done,
    this.keyboardType,
    this.minLines,
    this.maxLines = 1,
    this.onConfirm,
    this.onList,
    this.previewLoader,
  });

  final TextEditingController controller;
  final String title;
  final String labelText;
  final IconData prefixIcon;
  final bool useSystemKeyboard;
  final bool enabled;
  final OperationalKeyboardMode mode;
  final Color color;
  final bool allowDecimal;
  final bool obscure;
  final bool showListAction;
  final bool allowAlphaSwitch;
  final bool allowObservationSwitch;
  final bool clearOnOpen;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final int? minLines;
  final int maxLines;
  final VoidCallback? onConfirm;
  final VoidCallback? onList;
  final OperationalKeyboardPreviewLoader? previewLoader;

  Future<void> _openKeyboard(BuildContext context) async {
    if (!enabled) {
      return;
    }

    final initialValue = clearOnOpen ? '' : controller.text;
    if (clearOnOpen && controller.text.isNotEmpty) {
      controller.clear();
    }

    final result = await showOperationalKeyboard(
      context: context,
      title: title,
      initialValue: initialValue,
      mode: mode,
      color: color,
      allowDecimal: allowDecimal,
      obscure: obscure,
      showListAction: showListAction,
      allowAlphaSwitch: allowAlphaSwitch,
      allowObservationSwitch: allowObservationSwitch,
      previewLoader: previewLoader,
    );

    if (result == null) {
      return;
    }

    controller.text = result.value;
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );

    switch (result.action) {
      case OperationalKeyboardAction.confirm:
        onConfirm?.call();
      case OperationalKeyboardAction.list:
        onList?.call();
      case OperationalKeyboardAction.back:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (useSystemKeyboard) {
      return TextField(
        controller: controller,
        autofocus: true,
        enabled: enabled,
        obscureText: obscure,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        minLines: minLines,
        maxLines: maxLines,
        onSubmitted: (_) => onConfirm?.call(),
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(prefixIcon),
        ),
      );
    }

    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: true,
      showCursor: false,
      obscureText: obscure,
      minLines: minLines,
      maxLines: maxLines,
      onTap: () => _openKeyboard(context),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: const Icon(Icons.keyboard_alt_outlined),
      ),
    );
  }
}

class OperationalKeyboardPage extends StatefulWidget {
  const OperationalKeyboardPage({
    super.key,
    required this.title,
    required this.initialValue,
    required this.mode,
    required this.color,
    required this.allowDecimal,
    required this.obscure,
    required this.showListAction,
    required this.allowAlphaSwitch,
    required this.allowObservationSwitch,
    required this.replaceInitialValueOnFirstInput,
    required this.previewLoader,
  });

  final String title;
  final String initialValue;
  final OperationalKeyboardMode mode;
  final Color color;
  final bool allowDecimal;
  final bool obscure;
  final bool showListAction;
  final bool allowAlphaSwitch;
  final bool allowObservationSwitch;
  final bool replaceInitialValueOnFirstInput;
  final OperationalKeyboardPreviewLoader? previewLoader;

  @override
  State<OperationalKeyboardPage> createState() =>
      _OperationalKeyboardPageState();
}

class _OperationalKeyboardPageState extends State<OperationalKeyboardPage> {
  late String _value;
  late OperationalKeyboardMode _mode;
  late String _title;
  late bool _replaceOnNextInput;
  Timer? _previewTimer;
  int _previewRequest = 0;
  bool _loadingPreview = false;
  String? _preview;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _mode = widget.mode;
    _title = widget.title;
    _replaceOnNextInput =
        widget.replaceInitialValueOnFirstInput &&
        widget.initialValue.isNotEmpty;
    _schedulePreview();
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    super.dispose();
  }

  void _append(String key) {
    if (_mode == OperationalKeyboardMode.numeric) {
      if (key == 'abc') {
        setState(() {
          _mode = OperationalKeyboardMode.alpha;
        });
        return;
      }
      if (key == 'obs') {
        setState(() {
          _mode = OperationalKeyboardMode.alpha;
          _title = 'informe a observacao';
          _value = '';
        });
        return;
      }
      if (key == ',' && !widget.allowDecimal) {
        return;
      }
      if (key == ',' && _value.contains(',')) {
        return;
      }
      if (key == ',' && _value.isEmpty) {
        key = '0,';
      }
    }

    setState(() {
      if (_replaceOnNextInput) {
        _value = '';
        _replaceOnNextInput = false;
      }
      _value += key;
    });
    _schedulePreview();
  }

  void _clear() {
    _previewRequest++;
    _previewTimer?.cancel();
    setState(() {
      _value = '';
      _replaceOnNextInput = false;
      _preview = null;
      _loadingPreview = false;
    });
  }

  void _delete() {
    if (_value.isEmpty) {
      return;
    }

    setState(() {
      if (_replaceOnNextInput) {
        _value = '';
        _replaceOnNextInput = false;
        return;
      }
      _value = _value.substring(0, _value.length - 1);
    });
    _schedulePreview();
  }

  void _finish(OperationalKeyboardAction action) {
    Navigator.of(
      context,
    ).pop(OperationalKeyboardResult(action: action, value: _value.trim()));
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _finish(OperationalKeyboardAction.confirm);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _finish(OperationalKeyboardAction.back);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      _delete();
      return KeyEventResult.handled;
    }

    final character = event.character;
    if (character == null || character.isEmpty) {
      return KeyEventResult.ignored;
    }

    final allowed = _mode == OperationalKeyboardMode.numeric
        ? RegExp(r'^[0-9,.]$')
        : RegExp(r'^[a-zA-Z0-9 ./,_-]$');
    if (!allowed.hasMatch(character)) {
      return KeyEventResult.ignored;
    }

    _append(character == '.' && widget.allowDecimal ? ',' : character);
    return KeyEventResult.handled;
  }

  void _schedulePreview() {
    final loader = widget.previewLoader;
    if (loader == null) {
      return;
    }

    _previewTimer?.cancel();
    final value = _value.trim();
    if (value.isEmpty) {
      _previewRequest++;
      setState(() {
        _preview = null;
        _loadingPreview = false;
      });
      return;
    }

    _previewTimer = Timer(const Duration(milliseconds: 220), () {
      _loadPreview(value, loader);
    });
  }

  Future<void> _loadPreview(
    String value,
    OperationalKeyboardPreviewLoader loader,
  ) async {
    final request = ++_previewRequest;
    setState(() {
      _loadingPreview = true;
    });

    try {
      final preview = await loader(value);
      if (!mounted || request != _previewRequest) {
        return;
      }

      setState(() {
        _preview = preview;
        _loadingPreview = false;
      });
    } catch (_) {
      if (!mounted || request != _previewRequest) {
        return;
      }

      setState(() {
        _preview = null;
        _loadingPreview = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: _handleKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Column(
              children: [
                _KeyboardHeader(title: _title, color: widget.color),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _replaceOnNextInput
                            ? theme.colorScheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.obscure ? '*' * _value.length : _value,
                            maxLines: 1,
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _KeyboardPreview(
                  loading: _loadingPreview,
                  preview: _preview,
                  visible: widget.previewLoader != null,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: _mode == OperationalKeyboardMode.numeric
                      ? _NumericKeyboard(
                          color: widget.color,
                          allowDecimal: widget.allowDecimal,
                          showAlpha: widget.allowAlphaSwitch,
                          showObservation: widget.allowObservationSwitch,
                          onKey: _append,
                        )
                      : _AlphaKeyboard(color: widget.color, onKey: _append),
                ),
                const SizedBox(height: 10),
                _ActionRows(
                  showListAction: widget.showListAction,
                  onClear: _clear,
                  onDelete: _delete,
                  onList: () => _finish(OperationalKeyboardAction.list),
                  onBack: () => _finish(OperationalKeyboardAction.back),
                  onConfirm: () => _finish(OperationalKeyboardAction.confirm),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyboardHeader extends StatelessWidget {
  const _KeyboardHeader({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 72,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
          ),
        ),
        SizedBox(
          height: 78,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KeyboardPreview extends StatelessWidget {
  const _KeyboardPreview({
    required this.loading,
    required this.preview,
    required this.visible,
  });

  final bool loading;
  final String? preview;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox(height: 0);
    }

    final theme = Theme.of(context);
    final text = loading ? 'consultando...' : preview ?? '';

    return SizedBox(
      height: 42,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          child: text.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  key: ValueKey(text),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      text,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _NumericKeyboard extends StatelessWidget {
  const _NumericKeyboard({
    required this.color,
    required this.allowDecimal,
    required this.showAlpha,
    required this.showObservation,
    required this.onKey,
  });

  final Color color;
  final bool allowDecimal;
  final bool showAlpha;
  final bool showObservation;
  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    final specialKey = showObservation
        ? 'obs'
        : showAlpha
        ? 'abc'
        : '';
    final rows = <List<String>>[
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      [allowDecimal ? ',' : '', '0', specialKey],
    ];

    return Column(
      children: [
        for (final row in rows) ...[
          Expanded(
            child: Row(
              children: [
                for (final key in row) ...[
                  Expanded(
                    child: key.isEmpty
                        ? const SizedBox.expand()
                        : _KeyboardKey(
                            label: key,
                            color: key == 'abc' || key == 'obs'
                                ? const Color(0xFFFFD500)
                                : color,
                            onTap: () => onKey(key),
                          ),
                  ),
                  if (key != row.last) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          if (row != rows.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _AlphaKeyboard extends StatelessWidget {
  const _AlphaKeyboard({required this.color, required this.onKey});

  final Color color;
  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    const rows = <List<String>>[
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm', '.', '/'],
    ];

    return Column(
      children: [
        for (final row in rows) ...[
          Expanded(
            child: Row(
              children: [
                for (final key in row) ...[
                  Expanded(
                    child: _KeyboardKey(
                      label: key,
                      color: color,
                      onTap: () => onKey(key),
                    ),
                  ),
                  if (key != row.last) const SizedBox(width: 5),
                ],
              ],
            ),
          ),
          if (row != rows.last) const SizedBox(height: 6),
        ],
        const SizedBox(height: 6),
        Expanded(
          child: _KeyboardKey(
            label: 'space',
            color: const Color(0xFF2AAEAA),
            onTap: () => onKey(' '),
          ),
        ),
      ],
    );
  }
}

class _ActionRows extends StatelessWidget {
  const _ActionRows({
    required this.showListAction,
    required this.onClear,
    required this.onDelete,
    required this.onList,
    required this.onBack,
    required this.onConfirm,
  });

  final bool showListAction;
  final VoidCallback onClear;
  final VoidCallback onDelete;
  final VoidCallback onList;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _KeyboardKey(
                    label: 'limpar',
                    color: const Color(0xFFF07B7D),
                    onTap: onClear,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _KeyboardKey(
                    label: showListAction ? 'listar' : '',
                    color: showListAction
                        ? const Color(0xFF2AAEAA)
                        : const Color(0xFFD6D6D6),
                    onTap: showListAction ? onList : null,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _KeyboardKey(
                    label: 'del',
                    color: const Color(0xFFF07B7D),
                    onTap: onDelete,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _KeyboardKey(
                    label: 'voltar',
                    color: const Color(0xFFA7A7A7),
                    onTap: onBack,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _KeyboardKey(
                    label: 'confirmar',
                    color: const Color(0xFF25AAA8),
                    onTap: onConfirm,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyboardKey extends StatefulWidget {
  const _KeyboardKey({
    required this.label,
    required this.color,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool compact;

  @override
  State<_KeyboardKey> createState() => _KeyboardKeyState();
}

class _KeyboardKeyState extends State<_KeyboardKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final color = !enabled
        ? widget.color
        : _pressed
        ? Colors.grey.shade700
        : widget.color;

    return GestureDetector(
      onTapDown: enabled
          ? (_) {
              setState(() {
                _pressed = true;
              });
              widget.onTap?.call();
            }
          : null,
      onTapUp: (_) => _release(),
      onTapCancel: _release,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.label,
                maxLines: 1,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: widget.compact ? 20 : 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _release() {
    if (!_pressed || !mounted) {
      return;
    }

    setState(() {
      _pressed = false;
    });
  }
}
