import 'package:flutter/material.dart';
import '../../widgets/modern_layout.dart';
import '../../widgets/modern_course_card.dart';
import '../student/oxygen_course_screen.dart';

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'In Progress',
    'Completed',
    'Not Started',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernLayout(
      title: 'My Courses',
      currentIndex: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () {
            // Show sorting options
            _showSortOptions();
          },
        ),
        const SizedBox(width: 8),
      ],
      child: _buildCoursesContent(),
    );
  }

  Widget _buildCoursesContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and Filter Bar
          _buildSearchAndFilterBar(),
          const SizedBox(height: 24),

          // Course Stats
          _buildCourseStats(),
          const SizedBox(height: 24),

          // Course Grid
          Expanded(child: _buildCourseGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Row(
      children: [
        // Search Bar
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search your courses',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Filter Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFilter,
              icon: const Icon(Icons.filter_list),
              items:
                  _filters.map((String filter) {
                    return DropdownMenuItem<String>(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFilter = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseStats() {
    return Row(
      children: [
        _buildStatCard('5', 'Total Courses', Icons.book, Colors.blue),
        const SizedBox(width: 16),
        _buildStatCard(
          '3',
          'In Progress',
          Icons.play_circle_fill,
          Colors.orange,
        ),
        const SizedBox(width: 16),
        _buildStatCard('2', 'Completed', Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(
    String count,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseGrid() {
    // We'll use a grid view for larger screens, list view for smaller screens
    bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    if (isLargeScreen) {
      // Grid view for tablets and desktop
      return GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: _buildCourseCards(),
      );
    } else {
      // List view for phones
      return ListView.separated(
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildCourseCards()[index],
      );
    }
  }

  List<Widget> _buildCourseCards() {
    return [
      ModernCourseCard(
        imageAsset: 'lib/assets/images/course.jpg',
        courseName: 'Diving Safety and Awareness',
        courseDescription:
            'Learn essential diving safety principles, equipment checks, and emergency procedures.',
        authorName: 'Mark Anderson',
        rating: 4.8,
        studentCount: 1254,
        status: 'owned',
        onTap: () {
          Navigator.pushNamed(context, '/course_detail');
        },
      ),
      ModernCourseCard(
        imageAsset: 'lib/assets/images/course2.jpg',
        courseName: 'Oxygen',
        courseDescription:
            'Comprehensive course on Oxygen administration and safety in diving operations.',
        authorName: 'Diving Safety Team',
        rating: 4.9,
        studentCount: 1420,
        status: 'owned',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OxygenCourseScreen()),
          );
        },
      ),
      ModernCourseCard(
        imageAsset: 'lib/assets/images/course2.jpg',
        courseName: 'Advanced Scuba Techniques',
        courseDescription:
            'Master advanced diving techniques including buoyancy control, navigation and night diving.',
        authorName: 'Sarah Johnson',
        rating: 4.5,
        studentCount: 3267,
        status: 'owned',
        onTap: () {
          Navigator.pushNamed(context, '/course_detail');
        },
      ),
      ModernCourseCard(
        imageAsset: 'lib/assets/images/course.jpg',
        courseName: 'Underwater Photography',
        courseDescription:
            'Capture stunning underwater images with proper lighting and composition techniques.',
        authorName: 'David Chen',
        rating: 4.7,
        studentCount: 2189,
        status: 'owned',
        onTap: () {
          Navigator.pushNamed(context, '/course_detail');
        },
      ),
    ];
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort Courses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSortOption('Recently Accessed', Icons.access_time),
              _buildSortOption('A-Z', Icons.sort_by_alpha),
              _buildSortOption('Progress (High to Low)', Icons.trending_down),
              _buildSortOption('Progress (Low to High)', Icons.trending_up),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        // Apply sorting
      },
    );
  }
}
