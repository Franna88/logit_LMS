import 'package:flutter/material.dart';
import '../../widgets/modern_layout.dart';
import '../../screens/modules/content_navigator.dart';
import '../../services/lesson_service.dart';

// Define the content types
enum ContentType { introduction, video, lesson, exercise, quiz, assessment }

// Class to hold content item data
class ContentItem {
  final String title;
  final ContentType type;
  final String duration;
  final bool isCompleted;
  final Map<String, dynamic>?
  additionalData; // Add this field for storing slide data

  ContentItem({
    required this.title,
    required this.type,
    required this.duration,
    required this.isCompleted,
    this.additionalData,
  });
}

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LessonService _lessonService = LessonService();
  bool _isLoading = true;
  List<ContentItem> _courseContent =
      []; // Changed from separate lesson lists to a single course content list
  final String _courseId =
      "diving_safety_course"; // Example course ID - replace with actual course ID from navigation

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLessonData();
  }

  Future<void> _loadLessonData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all lessons for the course
      final lessons = await _lessonService.getLessonsForCourse(_courseId);

      // If no lessons found, attempt to create sample data
      if (lessons.isEmpty) {
        debugPrint('No lessons found. Creating sample data...');
        await _lessonService.createSampleDataIfNeeded();
        // Try loading lessons again
        final newLessons = await _lessonService.getLessonsForCourse(_courseId);
        setState(() {
          _courseContent = newLessons;
          _isLoading = false;
        });
      } else {
        setState(() {
          _courseContent = lessons;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading lesson data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernLayout(
      title: 'Diving Safety and Awareness',
      currentIndex: -1, // No nav item selected as this is a detail screen
      showBackButton: true,
      child: Column(
        children: [
          // Course Header
          _buildCourseHeader(),

          // Tabs - More compact
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ), // Even smaller font
              indicatorWeight: 2, // Even thinner indicator
              padding: EdgeInsets.zero, // Remove padding
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 16,
              ), // Tighter label padding
              tabs: const [
                Tab(text: 'Modules', height: 36), // Further reduced height
                Tab(text: 'Discussion', height: 36), // Further reduced height
                Tab(text: 'Resources', height: 36), // Further reduced height
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _isLoading ? _buildLoadingIndicator() : _buildModulesTab(),
                _buildDiscussionTab(),
                _buildResourcesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading lesson content...'),
        ],
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Course Image (even smaller now)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'lib/assets/images/course.jpg',
              height: 100, // Further reduced height
              width: 140, // Reduced width
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          // Right: Course info and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course info row
                Row(
                  children: [
                    // Duration card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '7 weeks',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Instructor
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundImage: const AssetImage(
                              'lib/assets/images/profile.jpg',
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Mark Anderson',
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress section
                Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.45,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 5, // Even thinner progress bar
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '45%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Modules completed indicator
                Text(
                  '2 of 6 modules completed',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesTab() {
    if (_courseContent.isEmpty) {
      return const Center(
        child: Text(
          'No lessons available for this course',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildModuleSection(
          'Module 1: Introduction to Diving Safety',
          _courseContent,
        ),
      ],
    );
  }

  Widget _buildModuleSection(String title, List<ContentItem> contentItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: contentItems.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = contentItems[index];
              return ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        item.isCompleted
                            ? Colors.green.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _getContentTypeIcon(item.type),
                      color: item.isCompleted ? Colors.green : Colors.blue,
                      size: 18,
                    ),
                  ),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: item.isCompleted ? Colors.grey[600] : Colors.black87,
                    decoration:
                        item.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      _getContentTypeLabel(item.type),
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            item.isCompleted
                                ? Colors.grey[600]
                                : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.duration,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // Download file
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloading ${item.title}...')),
                    );
                  },
                ),
                onTap: () => _launchContent(item),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getContentTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.introduction:
        return Icons.info_outline;
      case ContentType.video:
        return Icons.videocam;
      case ContentType.lesson:
        return Icons.article;
      case ContentType.exercise:
        return Icons.code;
      case ContentType.quiz:
        return Icons.quiz;
      case ContentType.assessment:
        return Icons.assessment;
    }
  }

  String _getContentTypeLabel(ContentType type) {
    switch (type) {
      case ContentType.introduction:
        return 'Introduction';
      case ContentType.video:
        return 'Video';
      case ContentType.lesson:
        return 'Lesson';
      case ContentType.exercise:
        return 'Exercise';
      case ContentType.quiz:
        return 'Quiz';
      case ContentType.assessment:
        return 'Assessment';
    }
  }

  void _launchContent(ContentItem item) {
    // Find the current module from expanded modules list
    final moduleIndex = _findCurrentModuleIndex();
    if (moduleIndex < 0) return;

    // Get all content items in the current module
    final List<ContentItem> allContentItems = _getContentItemsForModule(
      moduleIndex,
    );

    // Find the index of the selected content item
    final contentIndex = allContentItems.indexWhere(
      (content) => content.title == item.title,
    );
    if (contentIndex < 0) return;

    // Navigate to the content
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ContentNavigator(
              moduleTitle: _getModuleTitle(moduleIndex),
              contentItems: allContentItems,
              initialContentIndex: contentIndex,
              onContentComplete: (index, isCompleted) {
                _markContentCompleted(moduleIndex, index, isCompleted);
              },
            ),
      ),
    );
  }

  int _findCurrentModuleIndex() {
    // Get the module titles in the same order as displayed in the UI
    final moduleTitles = [
      'Module 1: Introduction to Diving Safety',
      'Module 2: Dive Planning and Risk Assessment',
      'Module 3: Emergency Procedures',
      'Module 4: Equipment Safety',
      'Module 5: Environmental Awareness',
      'Module 6: Advanced Safety Techniques',
    ];

    // For the demo, we're specifically looking for bleeding/emergency slides in Module 3
    // This simulates a more sophisticated mechanism that would identify the current module
    if (_tabController.index == 0) {
      // If we're on the Modules tab
      // Return index 2 which corresponds to Module 3: Emergency Procedures for BLEEDING slides
      return 2;
    }

    return 0; // Default to first module
  }

  List<ContentItem> _getContentItemsForModule(int moduleIndex) {
    // In a real app, this would come from your backend or state management
    switch (moduleIndex) {
      case 0:
        // Module 1 content
        return [
          ContentItem(
            title: 'Introduction to the Course',
            type: ContentType.introduction,
            duration: '5 min',
            isCompleted: true,
          ),
          // Other Module 1 items...
        ];
      case 1:
        // Module 2 content
        return [
          ContentItem(
            title: 'Dive Planning Basics',
            type: ContentType.video,
            duration: '20 min',
            isCompleted: true,
          ),
          // Other Module 2 items...
        ];
      case 2:
        // Module 3: Emergency Procedures - Including our BLEEDING slides
        return [
          ContentItem(
            title: 'Slide 1: BLEEDING',
            type: ContentType.lesson,
            duration: '5 min',
            isCompleted: false,
            additionalData: {
              'slideNumber': 1,
              'title': 'BLEEDING\n\nManaging cuts and wounds underwater',
              'content': [
                'Emergency procedures for divers',
                'First aid for underwater injuries',
                'Safety protocols for bleeding control',
              ],
              'images': [
                {
                  'url':
                      'https://cdn.pixabay.com/photo/2017/05/08/13/15/spring-bird-2295434_1280.jpg',
                  'description': 'Example image for demonstration purposes',
                },
              ],
            },
          ),
          ContentItem(
            title: 'Slide 2: BLEEDING',
            type: ContentType.lesson,
            duration: '5 min',
            isCompleted: false,
            additionalData: {
              'slideNumber': 2,
              'title': 'BLEEDING\n\nPressure Points and First Aid',
              'content': [
                'Apply direct pressure to the wound',
                'Elevate the affected area if possible',
                'Use pressure points for severe bleeding',
              ],
              'images': [
                {
                  'url':
                      'https://cdn.pixabay.com/photo/2014/02/27/16/10/flowers-276014_1280.jpg',
                  'description': 'Example image for demonstration purposes',
                },
              ],
            },
          ),
          ContentItem(
            title: 'Slide 3: BLEEDING',
            type: ContentType.lesson,
            duration: '5 min',
            isCompleted: false,
            additionalData: {
              'slideNumber': 3,
              'title': 'BLEEDING\n\nEmergency Response Steps',
              'content': [
                'Signal your buddy immediately',
                'Ascend slowly following safety procedures',
                'Apply first aid when at surface',
              ],
              'images': [
                {
                  'url':
                      'https://cdn.pixabay.com/photo/2013/07/21/13/00/rose-165819_1280.jpg',
                  'description': 'Example image for demonstration purposes',
                },
              ],
            },
          ),
          ContentItem(
            title: 'Slide 4: TREATMENT OF SOFT TISSUE INJURIES',
            type: ContentType.lesson,
            duration: '5 min',
            isCompleted: false,
            additionalData: {
              'slideNumber': 4,
              'title':
                  'TREATMENT OF SOFT TISSUE INJURIES\n\nHandling cuts, abrasions and lacerations',
              'content': [
                'Clean the wound with fresh water',
                'Apply antiseptic solution',
                'Cover with waterproof bandage',
                'Seek medical attention for serious wounds',
              ],
              'images': [
                {
                  'url':
                      'https://cdn.pixabay.com/photo/2016/12/13/05/15/puppy-1903313_1280.jpg',
                  'description': 'Example image for demonstration purposes',
                },
              ],
            },
          ),
          ContentItem(
            title: 'Slide 5: SHOCK',
            type: ContentType.lesson,
            duration: '5 min',
            isCompleted: false,
            additionalData: {
              'slideNumber': 5,
              'title':
                  'SHOCK\n\nRecognizing and treating shock in diving emergencies',
              'content': [
                'Signs: Pale skin, rapid breathing, weakness, confusion',
                'Lay victim flat, elevate legs if no spinal injury',
                'Maintain body temperature',
                'Provide oxygen if available',
                'Call emergency services immediately',
              ],
              'images': [
                {
                  'url':
                      'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg',
                  'description': 'Example image for demonstration purposes',
                },
              ],
            },
          ),
        ];
      default:
        return [];
    }
  }

  String _getModuleTitle(int moduleIndex) {
    // In a real app, this would come from your data model
    // For this demo, we'll return fixed module titles
    final modules = [
      'Module 1: Introduction to Diving Safety',
      'Module 2: Dive Planning and Risk Assessment',
      'Module 3: Emergency Procedures',
      'Module 4: Equipment Safety',
      'Module 5: Environmental Awareness',
      'Module 6: Advanced Safety Techniques',
    ];

    if (moduleIndex >= 0 && moduleIndex < modules.length) {
      return modules[moduleIndex];
    }
    return 'Module';
  }

  void _markContentCompleted(
    int moduleIndex,
    int contentIndex,
    bool completed,
  ) {
    // In a real app, this would update your data model and perhaps sync with a backend
    // For this demo, we'll just print a message
    print(
      'Marked content at module $moduleIndex, content $contentIndex as ${completed ? "completed" : "not completed"}',
    );

    // TODO: Update the UI to reflect this change when returning to the course detail screen
  }

  Widget _buildDiscussionTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Discussion Forum',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // New question input
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ask a Question',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Type your question here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                    label: const Text('Post Question'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Discussion threads
        const Text(
          'Recent Discussions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Thread 1
        _buildDiscussionThread(
          username: 'Alex Johnson',
          role: 'Instructor',
          time: '2 days ago',
          question:
              'What\'s the difference between StatefulWidget and StatelessWidget?',
          replies: 4,
          isAnswered: true,
        ),
        const SizedBox(height: 12),

        // Thread 2
        _buildDiscussionThread(
          username: 'Sarah Williams',
          role: 'Student',
          time: '1 day ago',
          question:
              'I\'m getting an error when implementing the Provider package. Can someone help?',
          replies: 2,
          isAnswered: true,
        ),
        const SizedBox(height: 12),

        // Thread 3
        _buildDiscussionThread(
          username: 'Michael Lee',
          role: 'Student',
          time: '5 hours ago',
          question:
              'What\'s the best approach for handling form validation in Flutter?',
          replies: 1,
          isAnswered: false,
        ),
      ],
    );
  }

  Widget _buildDiscussionThread({
    required String username,
    required String role,
    required String time,
    required String question,
    required int replies,
    required bool isAnswered,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      role == 'Instructor' ? Colors.blue : Colors.orange,
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        role == 'Instructor'
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      fontSize: 12,
                      color: role == 'Instructor' ? Colors.blue : Colors.orange,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(question, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.forum, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '$replies replies',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                if (isAnswered) ...[
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Answered',
                    style: TextStyle(fontSize: 14, color: Colors.green[600]),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to thread detail
                  },
                  child: const Text('View Discussion'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Course Resources',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Resource Categories
        _buildResourceCategory(
          title: 'Course Materials',
          resources: [
            Resource(
              title: 'Course Syllabus',
              fileType: 'PDF',
              fileSize: '1.2 MB',
              icon: Icons.picture_as_pdf,
              color: Colors.red,
            ),
            Resource(
              title: 'Flutter Installation Guide',
              fileType: 'PDF',
              fileSize: '2.5 MB',
              icon: Icons.picture_as_pdf,
              color: Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildResourceCategory(
          title: 'Code Samples',
          resources: [
            Resource(
              title: 'Module 1 Code Examples',
              fileType: 'ZIP',
              fileSize: '3.7 MB',
              icon: Icons.folder_zip,
              color: Colors.amber,
            ),
            Resource(
              title: 'Module 2 Code Examples',
              fileType: 'ZIP',
              fileSize: '4.2 MB',
              icon: Icons.folder_zip,
              color: Colors.amber,
            ),
            Resource(
              title: 'Module 3 Code Examples',
              fileType: 'ZIP',
              fileSize: '5.1 MB',
              icon: Icons.folder_zip,
              color: Colors.amber,
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildResourceCategory(
          title: 'Additional Reading',
          resources: [
            Resource(
              title: 'Flutter Documentation',
              fileType: 'Link',
              fileSize: 'External',
              icon: Icons.link,
              color: Colors.blue,
            ),
            Resource(
              title: 'State Management Patterns',
              fileType: 'PDF',
              fileSize: '1.8 MB',
              icon: Icons.picture_as_pdf,
              color: Colors.red,
            ),
            Resource(
              title: 'UI Design Guidelines',
              fileType: 'PDF',
              fileSize: '3.2 MB',
              icon: Icons.picture_as_pdf,
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResourceCategory({
    required String title,
    required List<Resource> resources,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: resources.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final resource = resources[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: resource.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(resource.icon, color: resource.color, size: 20),
                  ),
                ),
                title: Text(resource.title),
                subtitle: Text(
                  '${resource.fileType} • ${resource.fileSize}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // Download file
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Downloading ${resource.title}...'),
                      ),
                    );
                  },
                ),
                onTap: () {
                  // Open file or link
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// Helper classes
class Resource {
  final String title;
  final String fileType;
  final String fileSize;
  final IconData icon;
  final Color color;

  Resource({
    required this.title,
    required this.fileType,
    required this.fileSize,
    required this.icon,
    required this.color,
  });
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
