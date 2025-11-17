import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/database/indexed_db_service.dart';
import '../core/database/models/item_model.dart';
import 'item_state.dart';

class ItemCubit extends Cubit<ItemState> {
  final IndexedDBService _dbService;

  ItemCubit(this._dbService) : super(const ItemInitial());

  Future<void> loadItems() async {
    try {
      emit(const ItemLoading());
      final items = await _dbService.getAllItems();
      emit(ItemLoaded(items: items, filteredItems: items));
    } catch (e) {
      emit(ItemError('Erro ao carregar itens: $e'));
    }
  }

  Future<void> createItem(ItemModel item) async {
    try {
      await _dbService.createItem(item);
      
      final currentState = state;
      if (currentState is ItemLoaded) {
        final updatedItems = [...currentState.items, item];
        emit(ItemLoaded(items: updatedItems, filteredItems: updatedItems));
      } else {
        emit(const ItemLoading());
        try {
          final items = await _dbService.getAllItems().timeout(
            const Duration(seconds: 3),
            onTimeout: () => <ItemModel>[item],
          );
          emit(ItemLoaded(items: items, filteredItems: items));
        } catch (e) {
          emit(ItemLoaded(items: [item], filteredItems: [item]));
        }
      }
    } catch (e) {
      emit(ItemError('Erro ao criar item: $e'));
    }
  }

  Future<void> updateItem(ItemModel item) async {
    try {
      await _dbService.updateItem(item);
      
      final currentState = state;
      if (currentState is ItemLoaded) {
        final updatedItems = currentState.items.map((i) {
          return i.id == item.id ? item : i;
        }).toList();
        emit(ItemLoaded(items: updatedItems, filteredItems: updatedItems));
      } else {
        emit(const ItemLoading());
        try {
          final items = await _dbService.getAllItems().timeout(
            const Duration(seconds: 3),
            onTimeout: () => <ItemModel>[item],
          );
          emit(ItemLoaded(items: items, filteredItems: items));
        } catch (e) {
          emit(ItemLoaded(items: [item], filteredItems: [item]));
        }
      }
    } catch (e) {
      emit(ItemError('Erro ao atualizar item: $e'));
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      emit(const ItemLoading());
      await _dbService.deleteItem(id);
      await loadItems();
      emit(const ItemSuccess('Item deletado com sucesso!'));
    } catch (e) {
      emit(ItemError('Erro ao deletar item: $e'));
    }
  }

  void filterItems(String searchTerm) {
    final currentState = state;
    if (currentState is ItemLoaded) {
      if (searchTerm.isEmpty) {
        emit(ItemLoaded(
          items: currentState.items,
          filteredItems: currentState.items,
        ));
        return;
      }

      final lowerSearchTerm = searchTerm.toLowerCase();
      final filtered = currentState.items.where((item) {
        return item.name.toLowerCase().contains(lowerSearchTerm) ||
               item.description.toLowerCase().contains(lowerSearchTerm) ||
               item.category.toLowerCase().contains(lowerSearchTerm);
      }).toList();

      emit(ItemLoaded(
        items: currentState.items,
        filteredItems: filtered,
      ));
    }
  }

  Future<void> filterByCategory(String category) async {
    try {
      emit(const ItemLoading());
      final items = await _dbService.getItemsByCategory(category);
      final allItems = await _dbService.getAllItems();
      emit(ItemLoaded(items: allItems, filteredItems: items));
    } catch (e) {
      emit(ItemError('Erro ao filtrar por categoria: $e'));
    }
  }

  Future<void> filterByStatus(String status) async {
    try {
      emit(const ItemLoading());
      final items = await _dbService.getItemsByStatus(status);
      final allItems = await _dbService.getAllItems();
      emit(ItemLoaded(items: allItems, filteredItems: items));
    } catch (e) {
      emit(ItemError('Erro ao filtrar por status: $e'));
    }
  }

  void clearFilters() {
    final currentState = state;
    if (currentState is ItemLoaded) {
      emit(ItemLoaded(
        items: currentState.items,
        filteredItems: currentState.items,
      ));
    }
  }

  Map<String, dynamic> getStatistics() {
    final currentState = state;
    if (currentState is! ItemLoaded) {
      return {
        'total': 0,
        'byCategory': <String, int>{},
        'byStatus': <String, int>{},
        'totalValue': 0.0,
      };
    }

    final items = currentState.items;
    final byCategory = <String, int>{};
    final byStatus = <String, int>{};
    double totalValue = 0.0;

    for (final item in items) {
      byCategory[item.category] = (byCategory[item.category] ?? 0) + 1;
      byStatus[item.status] = (byStatus[item.status] ?? 0) + 1;
      totalValue += item.value;
    }

    return {
      'total': items.length,
      'byCategory': byCategory,
      'byStatus': byStatus,
      'totalValue': totalValue,
    };
  }
}

