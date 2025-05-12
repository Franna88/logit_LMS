import 'package:flutter/material.dart';
import 'admin_navigation.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final int currentIndex;
  final List<Widget>? actions;
  final bool showBackButton;

  const AdminLayout({
    super.key,
    required this.child,
    required this.title,
    required this.currentIndex,
    this.actions,
    this.showBackButton = false,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _isNavigationExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        leading:
            widget.showBackButton
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                )
                : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState!.openDrawer();
                  },
                ),
        actions: widget.actions,
        elevation: 0,
      ),
      drawer:
          MediaQuery.of(context).size.width < 1200
              ? Drawer(
                child: Container(
                  color: Colors.white,
                  child: AdminNavigation(
                    currentIndex: widget.currentIndex,
                    onDestinationSelected: (index) {},
                    isExpanded: true,
                    onExpandedChanged: (value) {},
                  ),
                ),
              )
              : null,
      body: Row(
        children: [
          // Show navigation sidebar on larger screens
          if (MediaQuery.of(context).size.width >= 1200)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: AdminNavigation(
                currentIndex: widget.currentIndex,
                onDestinationSelected: (index) {},
                isExpanded: _isNavigationExpanded,
                onExpandedChanged: (value) {
                  setState(() {
                    _isNavigationExpanded = value;
                  });
                },
              ),
            ),

          // Main content
          Expanded(
            child: Container(color: Colors.grey[50], child: widget.child),
          ),
        ],
      ),
    );
  }
}
