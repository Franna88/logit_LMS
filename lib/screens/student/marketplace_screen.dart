import 'package:flutter/material.dart';
import '../../widgets/modern_layout.dart';
import '../../widgets/modern_course_card.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Beginners',
    'Advanced',
    'Specialty',
    'Certification',
    'Equipment',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernLayout(
      title: 'Course Marketplace',
      currentIndex: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {
            // Show cart
          },
        ),
        const SizedBox(width: 8),
      ],
      child: _buildMarketplaceContent(),
    );
  }

  Widget _buildMarketplaceContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildCategorySelector(),
            const SizedBox(height: 24),
            _buildFeaturedSection(),
            const SizedBox(height: 24),
            const Text(
              'All Courses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCourseGrid(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search for courses',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.tune),
          onPressed: () {
            // Show advanced filters
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: Colors.blue.withOpacity(0.2),
              checkmarkColor: Colors.blue,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured Courses',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                child: ModernCourseCard(
                  imageAsset:
                      index % 2 == 0
                          ? 'lib/assets/images/course.jpg'
                          : 'lib/assets/images/course2.jpg',
                  courseName: _getFeaturedCourseName(index),
                  courseDescription: _getFeaturedCourseDescription(index),
                  authorName: _getFeaturedCourseAuthor(index),
                  rating: 4.8 - (index * 0.1),
                  studentCount: 2000 + (index * 500),
                  status: _getFeaturedCoursePrice(index),
                  onTap: () {
                    _showCourseDetails(context);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseGrid() {
    // We'll use a grid view for larger screens, list view for smaller screens
    bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    if (isLargeScreen) {
      // Grid view for tablets and desktop
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return ModernCourseCard(
              imageAsset:
                  index % 2 == 0
                      ? 'lib/assets/images/course.jpg'
                      : 'lib/assets/images/course2.jpg',
              courseName: _getCourseName(index),
              courseDescription: _getCourseDescription(index),
              authorName: _getCourseAuthor(index),
              rating: 4.5 + (index % 5) * 0.1,
              studentCount: 1000 + index * 300,
              status: _getCoursePrice(index),
              onTap: () {
                _showCourseDetails(context);
              },
            );
          },
        ),
      );
    } else {
      // List view for phones - non-scrollable since it's in a SingleChildScrollView
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ModernCourseCard(
              imageAsset:
                  index % 2 == 0
                      ? 'lib/assets/images/course.jpg'
                      : 'lib/assets/images/course2.jpg',
              courseName: _getCourseName(index),
              courseDescription: _getCourseDescription(index),
              authorName: _getCourseAuthor(index),
              rating: 4.5 + (index % 5) * 0.1,
              studentCount: 1000 + index * 300,
              status: _getCoursePrice(index),
              onTap: () {
                _showCourseDetails(context);
              },
            ),
          );
        },
      );
    }
  }

  String _getFeaturedCourseName(int index) {
    final List<String> names = [
      'PADI Open Water Certification',
      'Advanced Deep Diving',
      'Underwater Photography Masterclass',
    ];
    return index < names.length ? names[index] : 'Course ${index + 1}';
  }

  String _getFeaturedCourseDescription(int index) {
    final List<String> descriptions = [
      'Complete certification course for beginner divers with practical sessions.',
      'Master deep diving techniques and safety procedures for experienced divers.',
      'Learn to capture stunning underwater images with professional techniques.',
    ];
    return index < descriptions.length
        ? descriptions[index]
        : 'Comprehensive diving course for all levels.';
  }

  String _getFeaturedCourseAuthor(int index) {
    final List<String> authors = [
      'Mark Anderson',
      'Sarah Johnson',
      'David Chen',
    ];
    return index < authors.length ? authors[index] : 'Instructor ${index + 1}';
  }

  String _getFeaturedCoursePrice(int index) {
    final List<String> prices = ['\$59.99', '\$79.99', '\$69.99'];
    return index < prices.length ? prices[index] : '\$49.99';
  }

  String _getCourseName(int index) {
    final List<String> names = [
      'Night Diving Specialty',
      'Rescue Diver Certification',
      'Wreck Diving Adventures',
      'Coral Reef Conservation',
      'Drysuit Diving Techniques',
      'Underwater Navigation',
    ];
    return index < names.length ? names[index] : 'Diving Course ${index + 1}';
  }

  String _getCourseDescription(int index) {
    final List<String> descriptions = [
      'Master the skills needed for safe and enjoyable night diving experiences.',
      'Learn essential rescue techniques to handle diving emergencies effectively.',
      'Explore shipwrecks safely with specialized equipment and techniques.',
      'Understand coral reef ecosystems and how to protect these fragile environments.',
      'Stay warm and comfortable in cold water with proper drysuit techniques.',
      'Learn to navigate underwater using natural features and compass navigation.',
    ];
    return index < descriptions.length
        ? descriptions[index]
        : 'Comprehensive diving course for all experience levels.';
  }

  String _getCourseAuthor(int index) {
    final List<String> authors = [
      'Mark Anderson',
      'Sarah Johnson',
      'David Chen',
      'Maria Garcia',
      'James Wilson',
      'Emma Thompson',
    ];
    return index < authors.length ? authors[index] : 'Instructor ${index + 1}';
  }

  String _getCoursePrice(int index) {
    if (index == 4) return 'free';

    final List<String> prices = [
      '\$49.99',
      '\$39.99',
      '\$59.99',
      '\$29.99',
      'free',
      '\$44.99',
    ];
    return index < prices.length ? prices[index] : '\$39.99';
  }

  void _showCourseDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'lib/assets/images/course2.jpg',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),

                // Course Title
                const Text(
                  'PADI Advanced Open Water Certification',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Author and Rating
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue,
                      backgroundImage: const AssetImage(
                        'lib/assets/images/profile.jpg',
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Mark Anderson', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 16),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    const Text('4.9', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 16),
                    Icon(Icons.people, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '2,123 students',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Price
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '\$399.99',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                const Text(
                  'About this course',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Take your diving to the next level with the Advanced Open Water certification. This comprehensive course will teach you specialized dive skills including deep diving, underwater navigation, and night diving. Perfect for divers looking to expand their capabilities.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 24),

                // What you'll learn
                const Text(
                  'What you\'ll learn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildLearningPoint(
                  'Master deep diving techniques up to 30 meters/100 feet',
                ),
                _buildLearningPoint(
                  'Develop underwater navigation skills using compass and natural features',
                ),
                _buildLearningPoint(
                  'Learn night diving procedures and underwater communication',
                ),
                const Spacer(),

                // Purchase Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Course purchased successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Purchase Course',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLearningPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Icon(Icons.check_circle, color: Colors.green, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
