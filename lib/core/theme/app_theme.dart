import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6750A4);
  static const Color secondaryColor = Color(0xFF625B71);
  static const Color tertiaryColor = Color(0xFF7D5260);

  static const Color badgeGreen = Color(0xFFE8F5E9);
  static const Color badgePurple = Color(0xFFF3E5F5);
  
  static const Color selectedItemBackgroundLight = Color(0xFFF5F5F5);
  static const Color selectedItemBackgroundDark = Color(0xFF2C2C2C);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),

      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      dataTableTheme: DataTableThemeData(
        headingRowHeight: 56,
        dataRowHeight: 56,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withOpacity(0.12),
            ),
          ),
        ),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        selectedIconTheme: IconThemeData(
          color: colorScheme.primary,
        ),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),

      extensions: <ThemeExtension<dynamic>>[
        _CustomColors(
          badgeGreen: badgeGreen,
          badgePurple: badgePurple,
          selectedItemBackground: selectedItemBackgroundLight,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),

      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      dataTableTheme: DataTableThemeData(
        headingRowHeight: 56,
        dataRowHeight: 56,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withOpacity(0.12),
            ),
          ),
        ),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        selectedIconTheme: IconThemeData(
          color: colorScheme.primary,
        ),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),

      extensions: <ThemeExtension<dynamic>>[
        _CustomColors(
          badgeGreen: badgeGreen,
          badgePurple: badgePurple,
          selectedItemBackground: selectedItemBackgroundDark,
        ),
      ],
    );
  }
}

class _CustomColors extends ThemeExtension<_CustomColors> {
  final Color badgeGreen;
  final Color badgePurple;
  final Color selectedItemBackground;

  const _CustomColors({
    required this.badgeGreen,
    required this.badgePurple,
    required this.selectedItemBackground,
  });

  @override
  ThemeExtension<_CustomColors> copyWith({
    Color? badgeGreen,
    Color? badgePurple,
    Color? selectedItemBackground,
  }) {
    return _CustomColors(
      badgeGreen: badgeGreen ?? this.badgeGreen,
      badgePurple: badgePurple ?? this.badgePurple,
      selectedItemBackground: selectedItemBackground ?? this.selectedItemBackground,
    );
  }

  @override
  ThemeExtension<_CustomColors> lerp(
    ThemeExtension<_CustomColors>? other,
    double t,
  ) {
    if (other is! _CustomColors) {
      return this;
    }
    return _CustomColors(
      badgeGreen: Color.lerp(badgeGreen, other.badgeGreen, t)!,
      badgePurple: Color.lerp(badgePurple, other.badgePurple, t)!,
      selectedItemBackground: Color.lerp(selectedItemBackground, other.selectedItemBackground, t)!,
    );
  }
}

extension CustomColorsExtension on ThemeData {
  _CustomColors get customColors {
    return extension<_CustomColors>() ?? const _CustomColors(
      badgeGreen: AppTheme.badgeGreen,
      badgePurple: AppTheme.badgePurple,
      selectedItemBackground: AppTheme.selectedItemBackgroundLight,
    );
  }
}

