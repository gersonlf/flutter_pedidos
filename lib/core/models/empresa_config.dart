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
}

enum TrocaComandaPolicy { livre, exigeSenha, desabilitada }
