import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

Future<Database> openPedidosDatabaseForPlatform() async {
  final directory = await getApplicationDocumentsDirectory();
  final databasePath = p.join(directory.path, 'pedidos_local.db');
  return databaseFactoryIo.openDatabase(databasePath);
}
