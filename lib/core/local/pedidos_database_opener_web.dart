import 'package:sembast_web/sembast_web.dart';

Future<Database> openPedidosDatabaseForPlatform() {
  return databaseFactoryWeb.openDatabase('pedidos_local.db');
}
