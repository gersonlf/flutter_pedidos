import 'package:sembast/sembast.dart';

import 'pedidos_database_opener_stub.dart'
    if (dart.library.io) 'pedidos_database_opener_io.dart'
    if (dart.library.js_interop) 'pedidos_database_opener_web.dart';

Future<Database> openPedidosDatabase() {
  return openPedidosDatabaseForPlatform();
}
