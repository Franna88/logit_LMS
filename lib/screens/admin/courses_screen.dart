import 'package:flutter/material.dart';
import '../../widgets/admin_layout.dart';
import 'edit_course_screen.dart';

class CoursesScreen extends StatelessWidget {
  CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Courses',
      currentIndex: 1, // Courses tab
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Courses',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin_create_course');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search and filter
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search courses...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton(
                    hint: const Text('Status'),
                    items:
                        ['All', 'Published', 'Draft']
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Courses grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _sampleCourses.length,
              itemBuilder: (context, index) {
                final course = _sampleCourses[index];
                return _buildCourseCard(context, course);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/admin_edit_course',
            arguments: {'courseId': course['id'] as String},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                course['imageUrl'] as String,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          course['status'] == 'Published'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      course['status'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color:
                            course['status'] == 'Published'
                                ? Colors.green
                                : Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Course title
                  Text(
                    course['title'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Course modules count
                  Text(
                    '${course['moduleCount']} modules',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),

                  // Action buttons
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/admin_edit_course',
                            arguments: {'courseId': course['id'] as String},
                          );
                        },
                      ),
                      IconButton(
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Show delete confirmation
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Delete Course?'),
                                  content: Text(
                                    'Are you sure you want to delete "${course['title']}"? This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Delete course logic
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sample course data
  final List<Map<String, dynamic>> _sampleCourses = [
    {
      'id': '1',
      'title': 'Diving Safety and Awareness',
      'imageUrl': 'lib/assets/images/course.jpg',
      'status': 'Published',
      'moduleCount': 6,
    },
    {
      'id': '2',
      'title': 'Advanced Flutter Development',
      'imageUrl': 'lib/assets/images/course2.jpg',
      'status': 'Draft',
      'moduleCount': 8,
    },
    {
      'id': '3',
      'title': 'Web Development Basics',
      'imageUrl': 'lib/assets/images/course.jpg',
      'status': 'Published',
      'moduleCount': 5,
    },
    {
      'id': '4',
      'title': 'Environmental Awareness',
      'imageUrl': 'lib/assets/images/course2.jpg',
      'status': 'Published',
      'moduleCount': 4,
    },
    {
      'id': '5',
      'title': 'UI/UX Design Principles',
      'imageUrl': 'lib/assets/images/course.jpg',
      'status': 'Draft',
      'moduleCount': 7,
    },
    {
      'id': '6',
      'title': 'Mobile App Development',
      'imageUrl': 'lib/assets/images/course2.jpg',
      'status': 'Published',
      'moduleCount': 10,
    },
  ];
}
