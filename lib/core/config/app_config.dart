class AppConfig {
  const AppConfig({
    required this.server,
    required this.port,
    required this.context,
    required this.protocol,
    required this.physicalKeyboardEnabled,
    required this.commandCheckDigitEnabled,
    required this.requirePasswordToDelete,
  });

  factory AppConfig.defaults() {
    return const AppConfig(
      server: 'sem ip',
      port: 80,
      context: 'pedido.teste',
      protocol: AppProtocol.http,
      physicalKeyboardEnabled: false,
      commandCheckDigitEnabled: false,
      requirePasswordToDelete: false,
    );
  }

  final String server;
  final int port;
  final String context;
  final AppProtocol protocol;
  final bool physicalKeyboardEnabled;
  final bool commandCheckDigitEnabled;
  final bool requirePasswordToDelete;

  String get baseUrl => '${protocol.value}://$server:$port';

  String get phpContext => 'php-$context';

  Uri endpoint(String scriptName) {
    return Uri.parse('$baseUrl/$phpContext/$scriptName.php');
  }

  bool get isServerConfigured => server.trim().isNotEmpty && server != 'sem ip';

  AppConfig copyWith({
    String? server,
    int? port,
    String? context,
    AppProtocol? protocol,
    bool? physicalKeyboardEnabled,
    bool? commandCheckDigitEnabled,
    bool? requirePasswordToDelete,
  }) {
    return AppConfig(
      server: server ?? this.server,
      port: port ?? this.port,
      context: context ?? this.context,
      protocol: protocol ?? this.protocol,
      physicalKeyboardEnabled:
          physicalKeyboardEnabled ?? this.physicalKeyboardEnabled,
      commandCheckDigitEnabled:
          commandCheckDigitEnabled ?? this.commandCheckDigitEnabled,
      requirePasswordToDelete:
          requirePasswordToDelete ?? this.requirePasswordToDelete,
    );
  }
}

enum AppProtocol {
  http('http'),
  https('https');

  const AppProtocol(this.value);

  final String value;

  static AppProtocol fromValue(String value) {
    return AppProtocol.values.firstWhere(
      (protocol) => protocol.value == value,
      orElse: () => AppProtocol.http,
    );
  }
}
