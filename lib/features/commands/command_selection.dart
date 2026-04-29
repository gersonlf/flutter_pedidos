import '../../core/models/comanda.dart';

class CommandSelection {
  const CommandSelection({
    required this.codigoComanda,
    required this.codigoMesa,
    required this.codigoTag,
    required this.bloqueio,
    this.comanda,
  });

  final int codigoComanda;
  final int codigoMesa;
  final int codigoTag;
  final int bloqueio;
  final Comanda? comanda;

  bool get estaBloqueada => bloqueio != 0;

  String get resumo {
    final parts = ['CMD $codigoComanda'];
    if (codigoMesa > 0) {
      parts.add('Mesa $codigoMesa');
    }
    if (codigoTag > 0) {
      parts.add('Tag $codigoTag');
    }
    return parts.join(' - ');
  }
}
