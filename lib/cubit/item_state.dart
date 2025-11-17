import '../core/database/models/item_model.dart';

abstract class ItemState {
  const ItemState();
}

class ItemInitial extends ItemState {
  const ItemInitial();
}

class ItemLoading extends ItemState {
  const ItemLoading();
}

class ItemLoaded extends ItemState {
  final List<ItemModel> items;
  final List<ItemModel> filteredItems;

  const ItemLoaded({
    required this.items,
    required this.filteredItems,
  });

  ItemLoaded copyWith({
    List<ItemModel>? items,
    List<ItemModel>? filteredItems,
  }) {
    return ItemLoaded(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
    );
  }
}

class ItemError extends ItemState {
  final String message;

  const ItemError(this.message);
}

class ItemSuccess extends ItemState {
  final String message;

  const ItemSuccess(this.message);
}

