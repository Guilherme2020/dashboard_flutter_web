import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Icons.dashboard,
          color: theme.colorScheme.primary,
        ),
      ),
      title: const Text(
        'Dashboard',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          onSelected: (value) {
            if (value == 'logout') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout realizado')),
              );
            } else if (value == 'profile') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abrindo perfil')),
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 12),
                  const Text('Perfil'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: theme.colorScheme.error),
                  const SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

