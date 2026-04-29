class ItemComanda {
  const ItemComanda({
    required this.codigoVenda,
    required this.codigoComanda,
    required this.itemVenda,
    required this.codigoProduto,
    required this.descricaoProduto,
    required this.quantidade,
    required this.valorUnitario,
    required this.valorTotal,
    required this.observacao,
  });

  final int codigoVenda;
  final int codigoComanda;
  final int itemVenda;
  final int codigoProduto;
  final String descricaoProduto;
  final double quantidade;
  final double valorUnitario;
  final double valorTotal;
  final String observacao;

  factory ItemComanda.fromJson(Map<String, dynamic> json) {
    return ItemComanda(
      codigoVenda: _parseInt(json['codigo_venda']),
      codigoComanda: _parseInt(json['codigo_comanda']),
      itemVenda: _parseInt(json['item_venda']),
      codigoProduto: _parseInt(json['codigo_produto']),
      descricaoProduto: (json['descricao_produto'] ?? '').toString(),
      quantidade: _parseDouble(json['qtde_produto']),
      valorUnitario: _parseDouble(json['valor_unitario']),
      valorTotal: _parseDouble(json['valor_total']),
      observacao: (json['observacao_item'] ?? '').toString(),
    );
  }

  static int _parseInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '') ?? 0;
  }
}
