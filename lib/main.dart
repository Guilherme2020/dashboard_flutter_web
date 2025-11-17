import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/database/indexed_db_service.dart';
import 'core/theme/app_theme.dart';
import 'cubit/item_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'cubit/theme_state.dart';
import 'widgets/layout/app_layout.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/table/table_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dbService = IndexedDBService();
  await dbService.init();
  
  runApp(MyApp(dbService: dbService));
}

class MyApp extends StatelessWidget {
  final IndexedDBService dbService;

  const MyApp({super.key, required this.dbService});

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/dashboard',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return AppLayout(child: child);
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: '/products',
              builder: (context, state) => const TablePage(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = _createRouter();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ItemCubit(dbService)..loadItems()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Dashboard Flutter Web',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
