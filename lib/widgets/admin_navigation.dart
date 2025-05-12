import 'package:flutter/material.dart';

class AdminNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final bool isExpanded;
  final Function(bool) onExpandedChanged;

  const AdminNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.isExpanded,
    required this.onExpandedChanged,
  });

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.isExpanded ? 250 : 80,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          // Header with logo
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 16.0,
            ),
            child: Row(
              mainAxisAlignment:
                  widget.isExpanded
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
              children: [
                if (widget.isExpanded) ...[
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'DMT Admin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 24,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
                if (widget.isExpanded)
                  IconButton(
                    icon: Icon(
                      widget.isExpanded
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      widget.onExpandedChanged(!widget.isExpanded);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Divider with subtle color
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey[200],
          ),
          const SizedBox(height: 16),
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  0,
                  Icons.dashboard_outlined,
                  'Dashboard',
                  '/admin_dashboard',
                ),
                _buildNavItem(
                  1,
                  Icons.book_outlined,
                  'Courses',
                  '/admin_courses',
                ),
                _buildNavItem(
                  2,
                  Icons.add_circle_outline,
                  'Create Course',
                  '/admin_create_course',
                ),
                _buildNavItem(
                  3,
                  Icons.people_outline,
                  'Students',
                  '/admin_students',
                ),
                _buildNavItem(
                  4,
                  Icons.analytics_outlined,
                  'Analytics',
                  '/admin_analytics',
                ),
                _buildNavItem(
                  5,
                  Icons.settings_outlined,
                  'Settings',
                  '/admin_settings',
                ),
              ],
            ),
          ),
          // Footer section
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey[200],
          ),
          const SizedBox(height: 16),
          _buildNavItem(6, Icons.logout, 'Logout', '/login', isLogout: true),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    String route, {
    bool isLogout = false,
  }) {
    final isSelected = widget.currentIndex == index;
    final color = isLogout ? Colors.red : Colors.blue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: () {
          if (isLogout) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, route);
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
            );
          } else {
            widget.onDestinationSelected(index);
            Navigator.pushReplacementNamed(context, route);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey[600],
                size: 22,
              ),
              if (widget.isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected ? color : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
              if (widget.isExpanded && isSelected)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
