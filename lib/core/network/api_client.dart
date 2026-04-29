import '../config/app_config.dart';

class ApiClient {
  const ApiClient(this.config);

  final AppConfig config;

  Uri phpEndpoint(String scriptName) {
    return config.endpoint(scriptName);
  }
}
