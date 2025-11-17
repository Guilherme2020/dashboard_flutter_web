import 'package:flutter/material.dart';

class ProductsDraftPage extends StatelessWidget {
  const ProductsDraftPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Products - Draft',
              style: theme.textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}

