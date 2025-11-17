import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/theme_cubit.dart';
import '../../cubit/theme_state.dart';
import '../../core/theme/app_theme.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.customColors;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isLight = state.themeMode == ThemeMode.light;
        final isDark = state.themeMode == ThemeMode.dark;

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: customColors.selectedItemBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ThemeOption(
                  icon: Icons.light_mode,
                  label: 'Light',
                  isSelected: isLight,
                  onTap: () {
                    context.read<ThemeCubit>().setTheme(ThemeMode.light);
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _ThemeOption(
                  icon: Icons.dark_mode,
                  label: 'Dark',
                  isSelected: isDark,
                  onTap: () {
                    context.read<ThemeCubit>().setTheme(ThemeMode.dark);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.customColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.surface
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

