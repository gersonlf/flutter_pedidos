class PedidoCozinha {
  const PedidoCozinha({required this.codigoComanda});

  factory PedidoCozinha.fromJson(Map<String, dynamic> json) {
    return PedidoCozinha(codigoComanda: _parseInt(json['codigo_comanda']));
  }

  final int codigoComanda;

  static int _parseInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

enum PedidoCozinhaTipo {
  pronto('pedidoPronto', 'Prontos'),
  entregue('pedidoEntregue', 'Entregues');

  const PedidoCozinhaTipo(this.payload, this.label);

  final String payload;
  final String label;
}
