import 'package:flutter/material.dart';
import 'app_header.dart';
import 'app_sidebar.dart';

class AppLayout extends StatefulWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile) {
      return Scaffold(
        appBar: AppHeader(),
        drawer: AppSidebar(
          isCollapsed: false,
          onToggle: (collapsed) {
          },
        ),
        body: widget.child,
      );
    }

    return Scaffold(
      appBar: AppHeader(),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarCollapsed ? 72 : 250,
            constraints: BoxConstraints(
              minWidth: _isSidebarCollapsed ? 72 : 250,
              maxWidth: _isSidebarCollapsed ? 72 : 250,
            ),
            child: AppSidebar(
              isCollapsed: _isSidebarCollapsed,
              onToggle: (collapsed) {
                setState(() {
                  _isSidebarCollapsed = collapsed;
                });
              },
            ),
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

