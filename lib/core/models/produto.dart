class Produto {
  const Produto({
    required this.codigo,
    required this.codigoReduzido,
    required this.codigoBarra,
    required this.descricao,
    required this.grupo,
    required this.valorUnitario,
    required this.unidade,
    this.quantidadeAcompanhamento = 0,
  });

  final int codigo;
  final int codigoReduzido;
  final String codigoBarra;
  final String descricao;
  final int grupo;
  final double valorUnitario;
  final String unidade;
  final int quantidadeAcompanhamento;

  bool get permiteQuantidadeDecimal => unidade.toUpperCase() == 'KG';

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      codigo: _parseInt(json['codigo_produto']),
      codigoReduzido: _parseInt(json['codigo_reduzido']),
      codigoBarra: (json['codigo_barra'] ?? '').toString(),
      descricao: (json['descricao_produto'] ?? '').toString(),
      grupo: _parseInt(json['grupo_produto']),
      valorUnitario: _parseDouble(json['valor_unitario']),
      unidade: (json['unidade_produto'] ?? 'UN').toString(),
      quantidadeAcompanhamento: _parseInt(json['quantidade_acompanhamento']),
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
