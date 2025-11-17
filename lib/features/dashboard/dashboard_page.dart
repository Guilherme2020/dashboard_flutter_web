import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubit/item_cubit.dart';
import '../../../cubit/item_state.dart';
import '../../../widgets/charts/chart_widgets.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
                Text(
                  state.message,
                  style: theme.textTheme.bodyMedium,
                ),
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
          final cubit = context.read<ItemCubit>();
          final stats = cubit.getStatistics();
          
          final categoryData = Map<String, double>.from(
            (stats['byCategory'] as Map).map(
              (key, value) => MapEntry(key.toString(), (value as int).toDouble()),
            ),
          );

          final statusData = Map<String, double>.from(
            (stats['byStatus'] as Map).map(
              (key, value) => MapEntry(key.toString(), (value as int).toDouble()),
            ),
          );

          final items = state.items;
          final sortedItems = List.from(items)
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          
          final lineSpots = <FlSpot>[];
          double cumulativeValue = 0;
          for (int i = 0; i < sortedItems.length; i++) {
            cumulativeValue += sortedItems[i].value;
            lineSpots.add(FlSpot(i.toDouble(), cumulativeValue));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: _getCrossAxisCount(context),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.5,
                  children: [
                    _MetricCard(
                      title: 'Total de Itens',
                      value: stats['total'].toString(),
                      icon: Icons.inventory_2,
                      color: theme.colorScheme.primary,
                    ),
                    _MetricCard(
                      title: 'Valor Total',
                      value: 'R\$ ${(stats['totalValue'] as double).toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      color: theme.colorScheme.secondary,
                    ),
                    _MetricCard(
                      title: 'Categorias',
                      value: categoryData.length.toString(),
                      icon: Icons.category,
                      color: theme.colorScheme.tertiary,
                    ),
                    _MetricCard(
                      title: 'Status Ativos',
                      value: (stats['byStatus'] as Map)['active']?.toString() ?? '0',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                GridView.count(
                  crossAxisCount: _getCrossAxisCount(context),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    if (lineSpots.isNotEmpty)
                      LineChartWidget(
                        spots: lineSpots,
                        title: 'Tendência de Valores',
                      ),
                    if (categoryData.isNotEmpty)
                      BarChartWidget(
                        data: categoryData,
                        title: 'Distribuição por Categoria',
                      ),
                    if (statusData.isNotEmpty)
                      PieChartWidget(
                        data: statusData,
                        title: 'Distribuição por Status',
                      ),
                  ],
                ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 768) return 2;
    return 1;
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

