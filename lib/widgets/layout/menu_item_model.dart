import 'package:flutter/material.dart';

enum BadgeColor { green, purple }

class MenuItemModel {
  final IconData icon;
  final String label;
  final String? route;
  final List<MenuItemModel>? children;
  final int? badgeCount;
  final BadgeColor? badgeColor;
  final bool isExpanded;

  const MenuItemModel({
    required this.icon,
    required this.label,
    this.route,
    this.children,
    this.badgeCount,
    this.badgeColor,
    this.isExpanded = false,
  });

  bool get hasChildren => children != null && children!.isNotEmpty;

  MenuItemModel copyWith({
    IconData? icon,
    String? label,
    String? route,
    List<MenuItemModel>? children,
    int? badgeCount,
    BadgeColor? badgeColor,
    bool? isExpanded,
  }) {
    return MenuItemModel(
      icon: icon ?? this.icon,
      label: label ?? this.label,
      route: route ?? this.route,
      children: children ?? this.children,
      badgeCount: badgeCount ?? this.badgeCount,
      badgeColor: badgeColor ?? this.badgeColor,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

