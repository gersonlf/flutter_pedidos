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

  CommandSelection copyWith({
    int? codigoComanda,
    int? codigoMesa,
    int? codigoTag,
    int? bloqueio,
    Comanda? comanda,
  }) {
    return CommandSelection(
      codigoComanda: codigoComanda ?? this.codigoComanda,
      codigoMesa: codigoMesa ?? this.codigoMesa,
      codigoTag: codigoTag ?? this.codigoTag,
      bloqueio: bloqueio ?? this.bloqueio,
      comanda: comanda ?? this.comanda,
    );
  }

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
