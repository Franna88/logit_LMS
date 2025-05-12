import 'package:flutter/material.dart';
import '../../widgets/modern_layout.dart';
import '../../screens/modules/content_navigator.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                _buildModulesTab(),
                _buildDiscussionTab(),
                _buildResourcesTab(),
              ],
            ),
          ),
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
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ), // Further reduced padding
      children: [
        _buildModuleCard(
          title: 'Module 1: Introduction to Diving Safety',
          completedLessons: 4,
          totalLessons: 4,
          progress: 1.0,
          isCompleted: true,
          contentItems: [
            ContentItem(
              title: 'Introduction to the Course',
              type: ContentType.introduction,
              duration: '5 min',
              isCompleted: true,
            ),
            ContentItem(
              title: 'Diving Equipment Overview',
              type: ContentType.video,
              duration: '15 min',
              isCompleted: true,
            ),
            ContentItem(
              title: 'Pre-Dive Safety Checks',
              type: ContentType.lesson,
              duration: '25 min',
              isCompleted: true,
            ),
            ContentItem(
              title: 'Module Quiz',
              type: ContentType.quiz,
              duration: '10 min',
              isCompleted: true,
            ),
          ],
        ),
        const SizedBox(height: 6), // Further reduced spacing between modules
        _buildModuleCard(
          title: 'Module 2: Dive Planning and Risk Assessment',
          completedLessons: 5,
          totalLessons: 5,
          progress: 1.0,
          isCompleted: true,
          contentItems: [
            ContentItem(
              title: 'Dive Planning Basics',
              type: ContentType.video,
              duration: '20 min',
              isCompleted: true,
            ),
            ContentItem(
              title: 'Weather and Water Conditions',
              type: ContentType.video,
              duration: '25 min',
              isCompleted: true,
            ),
            ContentItem(
              title: 'Risk Assessment Techniques',
              type: ContentType.lesson,
              duration: '15 min',
              isCompleted: true,
            ),
            ContentItem(
              title: 'Creating a Dive Plan',
              type: ContentType.exercise,
              duration: '45 min',
              isCompleted: true,
            ),
            ContentItem(
              title: 'Module Quiz',
              type: ContentType.quiz,
              duration: '15 min',
              isCompleted: true,
            ),
          ],
        ),
        const SizedBox(height: 6), // Further reduced spacing
        _buildModuleCard(
          title: 'Module 3: Emergency Procedures',
          completedLessons: 2,
          totalLessons: 6,
          progress: 0.33,
          isCompleted: false,
          contentItems: [
            ContentItem(
              title: 'Recognizing Diving Emergencies',
              type: ContentType.video,
              duration: '20 min',
              isCompleted: true,
            ),
            ContentItem(
              title: 'First Aid for Divers',
              type: ContentType.lesson,
              duration: '15 min',
              isCompleted: true,
            ),
            ContentItem(
              title: 'Rescue Techniques',
              type: ContentType.video,
              duration: '30 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Emergency Ascent Procedures',
              type: ContentType.exercise,
              duration: '50 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Oxygen Administration',
              type: ContentType.lesson,
              duration: '25 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Module Quiz',
              type: ContentType.quiz,
              duration: '15 min',
              isCompleted: false,
            ),
          ],
        ),
        const SizedBox(height: 6), // Further reduced spacing
        _buildModuleCard(
          title: 'Module 4: Equipment Safety',
          completedLessons: 0,
          totalLessons: 5,
          progress: 0.0,
          isCompleted: false,
          contentItems: [
            ContentItem(
              title: 'Gear Inspection and Maintenance',
              type: ContentType.video,
              duration: '20 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Regulator Safety',
              type: ContentType.lesson,
              duration: '15 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Buoyancy Control Devices',
              type: ContentType.video,
              duration: '25 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Equipment Troubleshooting',
              type: ContentType.exercise,
              duration: '45 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Module Quiz',
              type: ContentType.quiz,
              duration: '15 min',
              isCompleted: false,
            ),
          ],
        ),
        const SizedBox(height: 6), // Further reduced spacing
        _buildModuleCard(
          title: 'Module 5: Environmental Awareness',
          completedLessons: 0,
          totalLessons: 6,
          progress: 0.0,
          isCompleted: false,
          contentItems: [
            ContentItem(
              title: 'Marine Hazards and Precautions',
              type: ContentType.video,
              duration: '25 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Conservation Practices',
              type: ContentType.lesson,
              duration: '20 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Current and Tide Safety',
              type: ContentType.video,
              duration: '30 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Night Diving Safety',
              type: ContentType.video,
              duration: '35 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Environmental Impact Assessment',
              type: ContentType.exercise,
              duration: '60 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Module Quiz',
              type: ContentType.quiz,
              duration: '15 min',
              isCompleted: false,
            ),
          ],
        ),
        const SizedBox(height: 6), // Further reduced spacing
        _buildModuleCard(
          title: 'Module 6: Advanced Safety Techniques',
          completedLessons: 0,
          totalLessons: 5,
          progress: 0.0,
          isCompleted: false,
          contentItems: [
            ContentItem(
              title: 'Deep Diving Safety',
              type: ContentType.video,
              duration: '35 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Decompression Procedures',
              type: ContentType.lesson,
              duration: '30 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Dive Computer Usage',
              type: ContentType.video,
              duration: '25 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Buddy System Protocols',
              type: ContentType.lesson,
              duration: '20 min',
              isCompleted: false,
            ),
            ContentItem(
              title: 'Final Safety Assessment',
              type: ContentType.assessment,
              duration: '120 min',
              isCompleted: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required String title,
    required int completedLessons,
    required int totalLessons,
    required double progress,
    required bool isCompleted,
    required List<ContentItem> contentItems,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6), // Reduced margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Reduced radius
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ), // Reduced font size
        ),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 0,
        ), // Reduced padding
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4), // Reduced spacing
            Text(
              '$completedLessons of $totalLessons lessons completed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ), // Smaller font
            ),
            const SizedBox(height: 6), // Reduced spacing
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Colors.blue,
              ),
              minHeight: 4, // Thinner progress bar
            ),
          ],
        ),
        leading: Container(
          width: 32, // Smaller icon container
          height: 32,
          decoration: BoxDecoration(
            color:
                isCompleted
                    ? Colors.green.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.play_circle_fill,
              color: isCompleted ? Colors.green : Colors.blue,
              size: 20, // Smaller icon
            ),
          ),
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_down,
          size: 20,
        ), // Smaller icon
        children: contentItems.map((item) => _buildContentItem(item)).toList(),
      ),
    );
  }

  Widget _buildContentItem(ContentItem item) {
    IconData getIcon() {
      switch (item.type) {
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

    Color getColor() {
      if (item.isCompleted) {
        return Colors.green;
      }
      switch (item.type) {
        case ContentType.introduction:
          return Colors.blue;
        case ContentType.video:
          return Colors.red;
        case ContentType.lesson:
          return Colors.orange;
        case ContentType.exercise:
          return Colors.purple;
        case ContentType.quiz:
          return Colors.amber;
        case ContentType.assessment:
          return Colors.indigo;
      }
    }

    // Return a more visually engaging content item with hover effect
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: getColor().withOpacity(0.3), width: 1.5),
      ),
      child: InkWell(
        onTap: () => _launchContent(item),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              // Icon with colored background
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: getColor().withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: getColor(), width: 1.5),
                ),
                child: Center(
                  child: Icon(getIcon(), color: getColor(), size: 18),
                ),
              ),
              const SizedBox(width: 12),

              // Title and completion status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            item.isCompleted
                                ? Colors.grey[600]
                                : Colors.black87,
                        decoration:
                            item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _getContentTypeLabel(item.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: getColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status icon
              if (item.isCompleted)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
    // This would be dynamic in a real app based on the current state
    // For this demo, we'll assume it matches the module index in the UI
    return 0; // Return the first module for demo purposes
  }

  List<ContentItem> _getContentItemsForModule(int moduleIndex) {
    // In a real app, this would come from your backend or state management
    // For this demo, we'll return sample content items based on module index
    switch (moduleIndex) {
      case 0:
        return [
          ContentItem(
            title: 'Introduction to the Course',
            type: ContentType.introduction,
            duration: '5 min',
            isCompleted: true,
          ),
          ContentItem(
            title: 'Diving Equipment Overview',
            type: ContentType.video,
            duration: '15 min',
            isCompleted: true,
          ),
          ContentItem(
            title: 'Pre-Dive Safety Checks',
            type: ContentType.lesson,
            duration: '25 min',
            isCompleted: true,
          ),
          ContentItem(
            title: 'Module Quiz',
            type: ContentType.quiz,
            duration: '10 min',
            isCompleted: true,
          ),
        ];
      case 1:
        return [
          ContentItem(
            title: 'Dive Planning Basics',
            type: ContentType.video,
            duration: '20 min',
            isCompleted: true,
          ),
          ContentItem(
            title: 'Weather and Water Conditions',
            type: ContentType.video,
            duration: '25 min',
            isCompleted: true,
          ),
          ContentItem(
            title: 'Risk Assessment Techniques',
            type: ContentType.lesson,
            duration: '15 min',
            isCompleted: true,
          ),
          ContentItem(
            title: 'Creating a Dive Plan',
            type: ContentType.exercise,
            duration: '45 min',
            isCompleted: true,
          ),
          ContentItem(
            title: 'Module Quiz',
            type: ContentType.quiz,
            duration: '15 min',
            isCompleted: true,
          ),
        ];
      case 2:
        return [
          ContentItem(
            title: 'Recognizing Diving Emergencies',
            type: ContentType.video,
            duration: '20 min',
            isCompleted: true,
          ),
          ContentItem(
            title: 'First Aid for Divers',
            type: ContentType.lesson,
            duration: '15 min',
            isCompleted: true,
          ),
          ContentItem(
            title: 'Rescue Techniques',
            type: ContentType.video,
            duration: '30 min',
            isCompleted: false,
          ),
          ContentItem(
            title: 'Emergency Ascent Procedures',
            type: ContentType.exercise,
            duration: '50 min',
            isCompleted: false,
          ),
          ContentItem(
            title: 'Oxygen Administration',
            type: ContentType.lesson,
            duration: '25 min',
            isCompleted: false,
          ),
          ContentItem(
            title: 'Module Quiz',
            type: ContentType.quiz,
            duration: '15 min',
            isCompleted: false,
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
enum ContentType { introduction, video, lesson, exercise, quiz, assessment }

class ContentItem {
  final String title;
  final ContentType type;
  final String duration;
  final bool isCompleted;

  ContentItem({
    required this.title,
    required this.type,
    required this.duration,
    required this.isCompleted,
  });
}

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
