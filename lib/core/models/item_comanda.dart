class ItemComanda {
  const ItemComanda({
    required this.codigoVenda,
    required this.codigoComanda,
    required this.itemVenda,
    required this.codigoProduto,
    this.codigoReduzido = 0,
    this.codigoBarra = '',
    required this.descricaoProduto,
    required this.quantidade,
    required this.valorUnitario,
    required this.valorTotal,
    required this.observacao,
    this.nomeFuncionario = '',
    this.dataHora = '',
  });

  final int codigoVenda;
  final int codigoComanda;
  final int itemVenda;
  final int codigoProduto;
  final int codigoReduzido;
  final String codigoBarra;
  final String descricaoProduto;
  final double quantidade;
  final double valorUnitario;
  final double valorTotal;
  final String observacao;
  final String nomeFuncionario;
  final String dataHora;

  factory ItemComanda.fromJson(Map<String, dynamic> json) {
    return ItemComanda(
      codigoVenda: _parseInt(json['codigo_venda']),
      codigoComanda: _parseInt(json['codigo_comanda']),
      itemVenda: _parseInt(json['item_venda']),
      codigoProduto: _parseInt(json['codigo_produto']),
      codigoReduzido: _parseInt(json['codigo_reduzido']),
      codigoBarra: (json['codigo_barra'] ?? '').toString(),
      descricaoProduto: (json['descricao_produto'] ?? '').toString(),
      quantidade: _parseDouble(json['qtde_produto']),
      valorUnitario: _parseDouble(json['valor_unitario']),
      valorTotal: _parseDouble(json['valor_total']),
      observacao: (json['observacao_item'] ?? '').toString(),
      nomeFuncionario: (json['nome_funcionario'] ?? '').toString(),
      dataHora: (json['data_hora'] ?? '').toString(),
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
