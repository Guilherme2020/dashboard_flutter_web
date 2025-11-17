import 'dart:async';
import 'package:idb_shim/idb.dart' as idb;
import 'package:idb_shim/idb_browser.dart';
import 'models/item_model.dart';

class IndexedDBService {
  static final IndexedDBService _instance = IndexedDBService._internal();
  factory IndexedDBService() => _instance;
  IndexedDBService._internal();

  static const String _dbName = 'dashboard_db';
  static const int _dbVersion = 1;
  static const String _storeName = 'items';

  idb.Database? _database;

  Future<void> init() async {
    if (_database != null) return;

    try {
      final idbFactory = idbFactoryBrowser;
      _database = await idbFactory.open(
        _dbName,
        version: _dbVersion,
        onUpgradeNeeded: (idb.VersionChangeEvent event) {
          final db = event.database;
          
          if (!db.objectStoreNames.contains(_storeName)) {
            final objectStore = db.createObjectStore(
              _storeName,
              keyPath: 'id',
              autoIncrement: false,
            );
            
            objectStore.createIndex('name', 'name', unique: false);
            objectStore.createIndex('category', 'category', unique: false);
            objectStore.createIndex('status', 'status', unique: false);
            objectStore.createIndex('createdAt', 'createdAt', unique: false);
          }
        },
      );
    } catch (e) {
      throw Exception('Erro ao inicializar IndexedDB: $e');
    }
  }

  void _ensureInitialized() {
    if (_database == null) {
      throw Exception('IndexedDB não foi inicializado. Chame init() primeiro.');
    }
  }

  Future<String> createItem(ItemModel item) async {
    _ensureInitialized();
    
    try {
      final transaction = _database!.transaction(_storeName, 'readwrite');
      final store = transaction.objectStore(_storeName);
      await store.put(item.toMap());
      await transaction.completed;
      return item.id;
    } catch (e) {
      throw Exception('Erro ao criar item: $e');
    }
  }

  Future<List<ItemModel>> getAllItems() async {
    _ensureInitialized();
    
    try {
      final transaction = _database!.transaction(_storeName, 'readonly');
      final store = transaction.objectStore(_storeName);
      
      final keys = await store.getAllKeys().timeout(
        const Duration(seconds: 5),
        onTimeout: () => <Object>[],
      );
      
      final List<ItemModel> items = [];
      
      for (final key in keys) {
        try {
          final map = await store.getObject(key).timeout(
            const Duration(seconds: 2),
            onTimeout: () => null,
          );
          
          if (map != null) {
            items.add(ItemModel.fromMap(Map<String, dynamic>.from(map as Map)));
          }
        } catch (e) {
          continue;
        }
      }
      
      await transaction.completed;
      return items;
    } catch (e) {
      return <ItemModel>[];
    }
  }

  Future<ItemModel?> getItemById(String id) async {
    _ensureInitialized();
    
    try {
      final transaction = _database!.transaction(_storeName, 'readonly');
      final store = transaction.objectStore(_storeName);
      final map = await store.getObject(id);
      
      if (map == null) return null;
      return ItemModel.fromMap(Map<String, dynamic>.from(map as Map));
    } catch (e) {
      throw Exception('Erro ao buscar item: $e');
    }
  }

  Future<void> updateItem(ItemModel item) async {
    _ensureInitialized();
    
    try {
      final transaction = _database!.transaction(_storeName, 'readwrite');
      final store = transaction.objectStore(_storeName);
      
      final updatedItem = item.copyWith(updatedAt: DateTime.now());
      await store.put(updatedItem.toMap());
      await transaction.completed;
    } catch (e) {
      throw Exception('Erro ao atualizar item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    _ensureInitialized();
    
    try {
      final transaction = _database!.transaction(_storeName, 'readwrite');
      final store = transaction.objectStore(_storeName);
      await store.delete(id);
      await transaction.completed;
    } catch (e) {
      throw Exception('Erro ao deletar item: $e');
    }
  }

  Future<List<ItemModel>> getItemsByCategory(String category) async {
    _ensureInitialized();
    
    try {
      final transaction = _database!.transaction(_storeName, 'readonly');
      final store = transaction.objectStore(_storeName);
      final index = store.index('category');
      final cursor = index.openCursor(key: category);
      
      final List<ItemModel> items = [];
      await for (final cursorWithValue in cursor) {
        final map = Map<String, dynamic>.from(cursorWithValue.value as Map);
        items.add(ItemModel.fromMap(map));
      }
      
      return items;
    } catch (e) {
      throw Exception('Erro ao buscar itens por categoria: $e');
    }
  }

  Future<List<ItemModel>> getItemsByStatus(String status) async {
    _ensureInitialized();
    
    try {
      final transaction = _database!.transaction(_storeName, 'readonly');
      final store = transaction.objectStore(_storeName);
      final index = store.index('status');
      final cursor = index.openCursor(key: status);
      
      final List<ItemModel> items = [];
      await for (final cursorWithValue in cursor) {
        final map = Map<String, dynamic>.from(cursorWithValue.value as Map);
        items.add(ItemModel.fromMap(map));
      }
      
      return items;
    } catch (e) {
      throw Exception('Erro ao buscar itens por status: $e');
    }
  }

  Future<List<ItemModel>> searchItemsByName(String searchTerm) async {
    _ensureInitialized();
    
    try {
      final allItems = await getAllItems();
      final lowerSearchTerm = searchTerm.toLowerCase();
      
      return allItems.where((item) {
        return item.name.toLowerCase().contains(lowerSearchTerm) ||
               item.description.toLowerCase().contains(lowerSearchTerm);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar itens por nome: $e');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      _database!.close();
      _database = null;
    }
  }
}
