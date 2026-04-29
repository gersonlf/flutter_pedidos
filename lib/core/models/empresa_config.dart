class EmpresaConfig {
  const EmpresaConfig({
    required this.controlaMesa,
    required this.controlaTag,
    required this.controlaTroca,
    required this.controlaCozinha,
  });

  final bool controlaMesa;
  final bool controlaTag;
  final TrocaComandaPolicy controlaTroca;
  final bool controlaCozinha;

  factory EmpresaConfig.defaults() {
    return const EmpresaConfig(
      controlaMesa: false,
      controlaTag: false,
      controlaTroca: TrocaComandaPolicy.livre,
      controlaCozinha: false,
    );
  }

  factory EmpresaConfig.fromJson(Map<String, dynamic> json) {
    return EmpresaConfig(
      controlaMesa: _isEnabled(json['controla_mesa']),
      controlaTag: _isEnabled(json['controla_tag']),
      controlaTroca: TrocaComandaPolicy.fromValue(json['controla_troca']),
      controlaCozinha: _isEnabled(json['controla_cozinha']),
    );
  }

  static bool _isEnabled(Object? value) {
    return value?.toString().trim().toUpperCase() == 'S';
  }
}

enum TrocaComandaPolicy {
  livre,
  exigeSenha,
  desabilitada;

  static TrocaComandaPolicy fromValue(Object? value) {
    return switch (value?.toString().trim().toUpperCase()) {
      'S' => TrocaComandaPolicy.exigeSenha,
      'D' => TrocaComandaPolicy.desabilitada,
      _ => TrocaComandaPolicy.livre,
    };
  }
}
