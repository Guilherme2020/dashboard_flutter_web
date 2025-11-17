import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubit/item_cubit.dart';
import '../../../cubit/item_state.dart';
import '../../../core/database/models/item_model.dart';
import '../drawer/item_drawer.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todas';
  String _selectedStatus = 'Todos';
  String _sortColumn = 'name';
  bool _sortAscending = true;
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<ItemCubit>().filterItems(_searchController.text);
  }

  List<String> _getCategories(List<ItemModel> items) {
    final categories = items.map((item) => item.category).toSet().toList();
    categories.sort();
    return ['Todas', ...categories];
  }

  List<String> _getStatuses() {
    return ['Todos', 'active', 'inactive', 'pending'];
  }

  void _sortTable(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  List<ItemModel> _sortItems(List<ItemModel> items) {
    final sorted = List<ItemModel>.from(items);
    sorted.sort((a, b) {
      int comparison = 0;
      switch (_sortColumn) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'category':
          comparison = a.category.compareTo(b.category);
          break;
        case 'value':
          comparison = a.value.compareTo(b.value);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ItemCubit, ItemState>(
      builder: (context, state) {
        if (state is ItemLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ItemError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar dados',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ItemCubit>().loadItems();
                  },
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (state is ItemLoaded) {
          var filteredItems = state.filteredItems;
          
          if (_selectedCategory != 'Todas') {
            filteredItems = filteredItems
                .where((item) => item.category == _selectedCategory)
                .toList();
          }
          
          if (_selectedStatus != 'Todos') {
            filteredItems = filteredItems
                .where((item) => item.status == _selectedStatus)
                .toList();
          }

          final sortedItems = _sortItems(filteredItems);

          final totalPages = (sortedItems.length / _itemsPerPage).ceil();
          final startIndex = _currentPage * _itemsPerPage;
          final endIndex = (startIndex + _itemsPerPage < sortedItems.length)
              ? startIndex + _itemsPerPage
              : sortedItems.length;
          final paginatedItems = sortedItems.sublist(
            startIndex,
            endIndex,
          );

          final categories = _getCategories(state.items);
          final statuses = _getStatuses();

          return Scaffold(
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Buscar por nome, descrição ou categoria...',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showDrawer(context, null);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Novo'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Categoria',
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value ?? 'Todas';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                prefixIcon: Icon(Icons.filter_list),
                              ),
                              items: statuses.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value ?? 'Todos';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = 'Todas';
                                _selectedStatus = 'Todos';
                                _searchController.clear();
                              });
                              context.read<ItemCubit>().clearFilters();
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Limpar Filtros'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: DataTable(
                            columnSpacing: 20,
                            columns: [
                              _buildDataColumn('name', 'Nome', theme),
                              _buildDataColumn('category', 'Categoria', theme),
                              _buildDataColumn('value', 'Valor', theme),
                              _buildDataColumn('status', 'Status', theme),
                              _buildDataColumn('createdAt', 'Data Criação', theme),
                              DataColumn(
                                label: Text(
                                  'Ações',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                            rows: paginatedItems.map((item) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(item.name)),
                                  DataCell(
                                    Chip(
                                      label: Text(item.category),
                                      backgroundColor: theme.colorScheme.primaryContainer,
                                    ),
                                  ),
                                  DataCell(Text(
                                    'R\$ ${item.value.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  )),
                                  DataCell(
                                    Chip(
                                      label: Text(_getStatusLabel(item.status)),
                                      backgroundColor: _getStatusColor(item.status, theme),
                                    ),
                                  ),
                                  DataCell(Text(
                                    '${item.createdAt.day.toString().padLeft(2, '0')}/${item.createdAt.month.toString().padLeft(2, '0')}/${item.createdAt.year}',
                                  )),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          color: theme.colorScheme.primary,
                                          onPressed: () {
                                            _showDrawer(context, item);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: theme.colorScheme.error,
                                          onPressed: () {
                                            _showDeleteDialog(context, item);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mostrando ${startIndex + 1}-${endIndex} de ${sortedItems.length} itens',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _currentPage > 0
                                ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            'Página ${_currentPage + 1} de $totalPages',
                            style: theme.textTheme.bodyMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _currentPage < totalPages - 1
                                ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  DataColumn _buildDataColumn(String column, String label, ThemeData theme) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      onSort: (columnIndex, ascending) {
        _sortTable(column);
      },
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'inactive':
        return 'Inativo';
      case 'pending':
        return 'Pendente';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'active':
        return Colors.green.withOpacity(0.2);
      case 'inactive':
        return Colors.grey.withOpacity(0.2);
      case 'pending':
        return Colors.orange.withOpacity(0.2);
      default:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  void _showDrawer(BuildContext context, ItemModel? item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ItemDrawer(
          item: item,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir o item "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ItemCubit>().deleteItem(item.id);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

