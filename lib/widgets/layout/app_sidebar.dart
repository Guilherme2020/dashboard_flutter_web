import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'menu_item_model.dart';
import 'hexagonal_logo.dart';
import 'theme_switcher.dart';
import '../../core/theme/app_theme.dart';

class AppSidebar extends StatefulWidget {
  final bool isCollapsed;
  final Function(bool) onToggle;

  const AppSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  String? _selectedRoute;
  final Map<String, bool> _expandedItems = {};

  final List<MenuItemModel> _menuItems = [
    MenuItemModel(
      icon: Icons.home,
      label: 'Home',
      route: '/dashboard',
    ),
    MenuItemModel(
      icon: Icons.inventory_2,
      label: 'Products',
      route: '/products',
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentRoute = GoRouterState.of(context).uri.path;
    _selectedRoute = currentRoute;

    if (widget.isCollapsed) {
      return _buildCollapsedSidebar(context, theme);
    }

    return _buildExpandedSidebar(context, theme);
  }

  Widget _buildCollapsedSidebar(BuildContext context, ThemeData theme) {
    return Container(
      width: 72,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: IconButton(
              icon: const HexagonalLogo(size: 32),
              onPressed: () => widget.onToggle(false),
              tooltip: 'Expandir menu',
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _isRouteSelected(item, _selectedRoute ?? '');
                return _buildCollapsedMenuItem(context, item, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedSidebar(BuildContext context, ThemeData theme) {
    final customColors = theme.customColors;

    return Container(
      width: 250,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const HexagonalLogo(size: 32),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => widget.onToggle(true),
                  tooltip: 'Colapsar menu',
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return _buildMenuItem(context, item, 0);
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHelpItem(context),
                const SizedBox(height: 16),
                const ThemeSwitcher(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    MenuItemModel item,
    int level,
  ) {
    final theme = Theme.of(context);
    final customColors = theme.customColors;
    final isSelected = _isRouteSelected(item, _selectedRoute ?? '');
    final isExpanded = _expandedItems[item.label] ?? false;
    final hasChildren = item.hasChildren;

    return Column(
      children: [
        InkWell(
          onTap: () {
            if (hasChildren) {
              setState(() {
                _expandedItems[item.label] = !isExpanded;
              });
            } else if (item.route != null) {
              context.go(item.route!);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: EdgeInsets.only(
              left: level * 16.0,
              right: 8,
              top: 2,
              bottom: 2,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected && !hasChildren
                  ? customColors.selectedItemBackground
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: isSelected && !hasChildren
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected && !hasChildren
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected && !hasChildren
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (hasChildren)
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  )
                else if (item.badgeCount != null)
                  _buildBadge(context, item.badgeCount!, item.badgeColor),
              ],
            ),
          ),
        ),
        if (hasChildren && isExpanded)
          ...item.children!.map((child) => _buildMenuItem(context, child, level + 1)),
      ],
    );
  }

  Widget _buildCollapsedMenuItem(
    BuildContext context,
    MenuItemModel item,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final customColors = theme.customColors;

    return Tooltip(
      message: item.label,
      child: InkWell(
        onTap: () {
          if (!item.hasChildren && item.route != null) {
            context.go(item.route!);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? customColors.selectedItemBackground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            size: 20,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, int count, BadgeColor? badgeColor) {
    final theme = Theme.of(context);
    final customColors = theme.customColors;
    final color = badgeColor == BadgeColor.green
        ? customColors.badgeGreen
        : customColors.badgePurple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.customColors;

    return InkWell(
      onTap: () {
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.help_outline,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Help & getting started',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            _buildBadge(context, 8, BadgeColor.purple),
          ],
        ),
      ),
    );
  }

  bool _isRouteSelected(MenuItemModel item, String currentRoute) {
    if (item.route == currentRoute) {
      return true;
    }
    if (item.hasChildren) {
      return item.children!.any((child) => _isRouteSelected(child, currentRoute));
    }
    return false;
  }
}
