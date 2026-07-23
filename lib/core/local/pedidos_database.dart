import 'package:sembast/sembast.dart';

import 'pedidos_database_opener.dart';

class PedidosDatabase {
  PedidosDatabase._(this._database);

  static PedidosDatabase? _instance;

  final Database _database;

  static Future<PedidosDatabase> open() async {
    final current = _instance;
    if (current != null) {
      return current;
    }

    final database = PedidosDatabase._(await openPedidosDatabase());
    _instance = database;
    return database;
  }

  StoreRef<String, Object?> store(String name) {
    return stringMapStoreFactory.store(name);
  }

  Future<void> putMetadata(String key, Object? value) async {
    await store('metadata').record(key).put(_database, value);
  }

  Future<Object?> getMetadata(String key) {
    return store('metadata').record(key).get(_database);
  }

  Future<String> enqueueSync({
    required String type,
    required Map<String, Object?> payload,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await store('sync_queue').record(id).put(_database, {
      'id': id,
      'type': type,
      'payload': payload,
      'created_at': DateTime.now().toIso8601String(),
      'status': 'pending',
    });
    return id;
  }

  Future<List<Map<String, Object?>>> pendingSyncItems() async {
    final records = await store('sync_queue').find(
      _database,
      finder: Finder(filter: Filter.equals('status', 'pending')),
    );

    return records
        .map((record) => Map<String, Object?>.from(record.value as Map))
        .toList();
  }
}
