class Funcionario {
  const Funcionario({required this.codigo, required this.nome});

  factory Funcionario.fromJson(Map<String, dynamic> json) {
    return Funcionario(
      codigo: _parseInt(json['codigo_funcionario']),
      nome: (json['nome_funcionario'] ?? '').toString(),
    );
  }

  factory Funcionario.fromPasswordJson(Map<String, dynamic> json) {
    return Funcionario(
      codigo: _parseInt(json['codigo']),
      nome: (json['nome'] ?? '').toString(),
    );
  }

  final int codigo;
  final String nome;

  static int _parseInt(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
