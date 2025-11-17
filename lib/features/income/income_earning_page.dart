import 'package:flutter/material.dart';

class IncomeEarningPage extends StatelessWidget {
  const IncomeEarningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Income - Earning',
              style: theme.textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}

