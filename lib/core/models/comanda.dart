class Comanda {
  const Comanda({
    required this.codigoEmpresa,
    required this.codigoVenda,
    required this.codigoComanda,
    required this.codigoMesa,
    required this.codigoTag,
    required this.dataHora,
    required this.bloqueio,
    required this.nomeFuncionario,
    required this.valorTotal,
  });

  final int codigoEmpresa;
  final int codigoVenda;
  final int codigoComanda;
  final int codigoMesa;
  final int codigoTag;
  final String dataHora;
  final int bloqueio;
  final String nomeFuncionario;
  final double valorTotal;

  bool get estaBloqueada => bloqueio != 0;

  factory Comanda.fromJson(Map<String, dynamic> json) {
    return Comanda(
      codigoEmpresa: _parseInt(json['codigo_empresa']),
      codigoVenda: _parseInt(json['codigo_venda']),
      codigoComanda: _parseInt(json['codigo_comanda']),
      codigoMesa: _parseInt(json['codigo_mesa']),
      codigoTag: _parseInt(json['codigo_tag']),
      dataHora: (json['data_hora'] ?? '').toString(),
      bloqueio: _parseInt(json['bloqueio']),
      nomeFuncionario: (json['nome_funcionario'] ?? '').toString(),
      valorTotal: _parseDouble(json['valor_total']),
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
