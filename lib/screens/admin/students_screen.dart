import 'package:flutter/material.dart';
import '../../widgets/admin_layout.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Students',
      currentIndex: 3, // Students tab
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // Show filter options
          },
        ),
        const SizedBox(width: 8),
      ],
      child: _buildStudentsContent(),
    );
  }

  Widget _buildStudentsContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search students...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Students list
          Expanded(child: _buildStudentsList()),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    final students = [
      {
        'name': 'John Smith',
        'email': 'john.smith@example.com',
        'courses': 3,
        'progress': 0.75,
        'avatar': 'assets/images/avatars/avatar1.png',
      },
      {
        'name': 'Sarah Johnson',
        'email': 'sarah.j@example.com',
        'courses': 2,
        'progress': 0.5,
        'avatar': 'assets/images/avatars/avatar2.png',
      },
      {
        'name': 'Michael Brown',
        'email': 'michael.brown@example.com',
        'courses': 4,
        'progress': 0.9,
        'avatar': 'assets/images/avatars/avatar3.png',
      },
      {
        'name': 'Emily Davis',
        'email': 'emily.davis@example.com',
        'courses': 1,
        'progress': 0.3,
        'avatar': 'assets/images/avatars/avatar4.png',
      },
    ];

    return ListView.separated(
      itemCount: students.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final student = students[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(student['name'].toString().substring(0, 1)),
          ),
          title: Text(student['name'] as String),
          subtitle: Text(student['email'] as String),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${student['courses']} courses'),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: student['progress'] as double,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Show options
                },
              ),
            ],
          ),
          onTap: () {
            // View student details
          },
        );
      },
    );
  }
}
