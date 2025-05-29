import 'package:flutter/material.dart';
import '../../widgets/modern_layout.dart';
import '../../screens/modules/content_navigator.dart';
import '../../services/lesson_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define the content types
enum ContentType { introduction, video, lesson, exercise, quiz, assessment }

// Define the assessment item class
class AssessmentItem {
  final String title;
  final String description;
  String competencyLevel; // Changed to mutable
  double score = 0.0; // Add score property

  AssessmentItem({
    required this.title,
    required this.description,
    required this.competencyLevel,
  });

  // Helper method to get score based on competency level
  double getScoreValue() {
    switch (competencyLevel) {
      case 'Competent':
      case 'Positive':
        return 1.0; // Full score
      case 'Knowledge Gap':
        return 0.75; // 75% score
      case 'Skill gap':
        return 0.5; // 50% score
      case 'Not Yet Competent':
      case 'Negative':
      case 'Lacks attention':
      default:
        return 0.0; // No score
    }
  }
}

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
  List<ContentItem> _lesson01Content = [];
  List<ContentItem> _lesson02Content = [];

  // For workplace assessment
  List<AssessmentItem> _assessmentItems =
      []; // Will be initialized in initState
  double _scoreValue = 7.5;
  TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLessonData();
    _initializeAssessmentItems();
  }

  void _initializeAssessmentItems() {
    // Initialize the assessment items with default values
    _assessmentItems = [
      // Safety First
      AssessmentItem(
        title: 'Safety First',
        description:
            'Ensures hands are clean and free from hand creams, oil and grease',
        competencyLevel: 'Not Yet Competent',
      ),
      AssessmentItem(
        title: 'Safety First',
        description: 'Ensure no open flames or sparks in work area',
        competencyLevel: 'Not Yet Competent',
      ),
      // Check the cylinder
      AssessmentItem(
        title: 'Check the cylinder',
        description:
            'Safety - Proper Position: Oxygen cylinder securely upright or lying down',
        competencyLevel: 'Not Yet Competent',
      ),
      AssessmentItem(
        title: 'Check the cylinder',
        description: 'Safety - no part of body over cylinder valve',
        competencyLevel: 'Not Yet Competent',
      ),
      AssessmentItem(
        title: 'Check the cylinder',
        description: 'Safety - correct cylinder colour coding and in date',
        competencyLevel: 'Not Yet Competent',
      ),
      // Step 9: Re-stock
      AssessmentItem(
        title: 'Step 9: Re-stock',
        description: 'Follows company procedure for restocking DMAC 015',
        competencyLevel: 'Not Yet Competent',
      ),
      // Attitude
      AssessmentItem(
        title: 'Attitude',
        description: 'Student displays proper attitude during assessment',
        competencyLevel: 'Negative',
      ),
    ];

    // Calculate initial score
    _updateAssessmentScore();
  }

  // Add a method to calculate and update the assessment score
  void _updateAssessmentScore() {
    if (_assessmentItems.isEmpty) return;

    int totalItems = _assessmentItems.length;
    double totalScore = 0.0;

    // Calculate total score based on competency levels
    for (var item in _assessmentItems) {
      totalScore += item.getScoreValue();
    }

    // Calculate percentage (0-100%)
    double percentage = (totalScore / totalItems) * 100;

    // Scale to 0-10 range for the scoreValue
    double newScore = (percentage / 100) * 10;

    // Ensure minimum score of 7.5 if at least 75% competent
    if (percentage >= 75) {
      newScore = newScore < 7.5 ? 7.5 : newScore;
    }

    // Update the score
    setState(() {
      _scoreValue = newScore;
    });
  }

  Future<void> _loadLessonData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load Lesson 01 content
      final lesson01Items = await _lessonService.getLesson01ContentItems();

      // Load Lesson 02 content
      final lesson02Items = await _lessonService.getLesson02ContentItems();

      setState(() {
        _lesson01Content = lesson01Items;
        _lesson02Content = lesson02Items;
        _isLoading = false;
      });
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
                Tab(text: 'Workplace Assessment', height: 36), // New tab
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
                _buildWorkplaceAssessmentTab(), // New tab content
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
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ), // Further reduced padding
      children: [
        // Use real lesson data in Module 3: Emergency Procedures
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
          completedLessons: 0,
          totalLessons: 5,
          progress: 0.0,
          isCompleted: false,
          contentItems: _getContentItemsForModule(
            2,
          ), // Get bleeding content from module index 2
        ),
        const SizedBox(height: 6), // Further reduced spacing
        _buildModuleCard(
          title: 'Module 4: Equipment Safety',
          completedLessons: _countCompletedLessons(_lesson02Content),
          totalLessons: _lesson02Content.length,
          progress: _calculateProgress(_lesson02Content),
          isCompleted: false,
          contentItems: _lesson02Content,
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

  // Helper methods for lesson progress
  int _countCompletedLessons(List<ContentItem> items) {
    return items.where((item) => item.isCompleted).length;
  }

  double _calculateProgress(List<ContentItem> items) {
    if (items.isEmpty) return 0.0;
    return _countCompletedLessons(items) / items.length;
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
                  'path':
                      'images/Lesson_01_slide_1_a5708d93-bb45-4572-9616-69c45188d6fa.png',
                  'description':
                      'Bleeding management procedures for open wounds',
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
              'title': 'BLEEDING\n\nCLOSED WOUNDS',
              'content': [
                'Unlike open wounds, closed wounds do not break the skin\'s surface',
                'Assess for pain, swelling and bruising in the affected area',
                'Check for contusions, strains and sprains',
              ],
              'images': [
                {
                  'path':
                      'images/Lesson_01_slide_4_2379cb9f-b8e6-417a-bebb-9ccb546977c3.png',
                  'description':
                      'RICER treatment protocol for soft tissue injuries',
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
                  'path':
                      'images/Lesson_01_slide_5_5cd6309f-1f57-4a19-87e9-ec5279ddd360.png',
                  'description':
                      'Signs and symptoms of shock in emergency situations',
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
              'title': 'TREATMENT OF SOFT TISSUE INJURIES\n\nRICER Protocol',
              'content': [
                'Rest - prevent further damage',
                'Ice - decrease swelling and pain',
                'Compression - reduce internal bleeding',
                'Elevation - reduce swelling',
                'Referral/Diagnosis - seek medical attention',
              ],
              'images': [
                {
                  'path':
                      'images/Lesson_01_slide_6_ae28a4dc-4a14-4397-82f1-a1aae2c7aba8.png',
                  'description':
                      'Different types of shock and their characteristics',
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
                  'path':
                      'images/Lesson_02_slide_1_37374d19-33c2-4c33-8f26-d0eb1ef05112.png',
                  'description':
                      'Pneumothorax diagnosis and emergency management',
                },
                {
                  'path':
                      'images/Lesson_01_slide_14_51d20603-dd70-47d3-8dba-e2f776ed5b8b.png',
                  'description':
                      'Flail chest treatment and management procedure',
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

  // Build the Workplace Assessment tab content
  Widget _buildWorkplaceAssessmentTab() {
    // Group items by title
    Map<String, List<AssessmentItem>> groupedItems = {};
    for (var item in _assessmentItems) {
      if (!groupedItems.containsKey(item.title)) {
        groupedItems[item.title] = [];
      }
      groupedItems[item.title]!.add(item);
    }

    // Calculate assessment progress - items with competent status
    int completedItems =
        _assessmentItems
            .where(
              (item) =>
                  item.competencyLevel == 'Competent' ||
                  item.competencyLevel == 'Positive',
            )
            .length;
    double progress =
        _assessmentItems.isEmpty
            ? 0.0
            : completedItems / _assessmentItems.length;

    return Column(
      children: [
        // Progress section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.assessment, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Assessment Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$completedItems of ${_assessmentItems.length} completed',
                    style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0 ? Colors.green : Colors.blue,
                ),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Score: ${_scoreValue.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Text(
                    _scoreValue >= 7.5 ? 'PASS' : 'NEEDS IMPROVEMENT',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _scoreValue >= 7.5 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Assessment items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Assessment items grouped by section
              ...groupedItems.entries.map((entry) {
                String title = entry.key;
                List<AssessmentItem> items = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Assessment items
                      ...items.map((item) {
                        if (item.title == 'Attitude') {
                          return _buildAttitudeRow(item);
                        } else {
                          return _buildAssessmentItemRow(item);
                        }
                      }),

                      const SizedBox(height: 8),
                    ],
                  ),
                );
              }).toList(),

              // Remarks section
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Remarks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Extra remarks regarding this assessment',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextField(
                              controller: _remarksController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(12),
                                border: InputBorder.none,
                                hintText: 'Enter additional remarks here...',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Score Breakdown Card
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Score Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Score indicator
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    '0',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 8,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 8,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                            overlayRadius: 16,
                                          ),
                                      activeTrackColor: Colors.blue,
                                      inactiveTrackColor: Colors.grey.shade200,
                                      thumbColor: Colors.blue,
                                    ),
                                    child: Slider(
                                      value: _scoreValue,
                                      min: 0,
                                      max: 10,
                                      divisions: 20,
                                      onChanged: null, // Make it read-only
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    '10',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current score: ${_scoreValue.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _scoreValue >= 7.5
                                ? 'Score is sufficient (minimum passing score is 7.5)'
                                : 'Score needs improvement (minimum passing score is 7.5)',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  _scoreValue >= 7.5
                                      ? Colors.green
                                      : Colors.red,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Score breakdown
                          const Text(
                            'Score Breakdown:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Competent count
                          _buildScoreBreakdownRow(
                            'Competent/Positive',
                            _assessmentItems
                                .where(
                                  (item) =>
                                      item.competencyLevel == 'Competent' ||
                                      item.competencyLevel == 'Positive',
                                )
                                .length,
                            '(100% value)',
                            Colors.green,
                          ),

                          // Knowledge Gap count
                          _buildScoreBreakdownRow(
                            'Knowledge Gap',
                            _assessmentItems
                                .where(
                                  (item) =>
                                      item.competencyLevel == 'Knowledge Gap',
                                )
                                .length,
                            '(75% value)',
                            Colors.orange,
                          ),

                          // Skill Gap count
                          _buildScoreBreakdownRow(
                            'Skill gap',
                            _assessmentItems
                                .where(
                                  (item) => item.competencyLevel == 'Skill gap',
                                )
                                .length,
                            '(50% value)',
                            Colors.amber,
                          ),

                          // Not Competent count
                          _buildScoreBreakdownRow(
                            'Not Yet Competent/Empty',
                            _assessmentItems
                                .where(
                                  (item) =>
                                      item.competencyLevel ==
                                          'Not Yet Competent' ||
                                      item.competencyLevel == '',
                                )
                                .length,
                            '(0% value)',
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Save button section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Handle save action
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Assessment saved successfully'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper widget to display score breakdown rows
  Widget _buildScoreBreakdownRow(
    String label,
    int count,
    String valueText,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 12)),
          Text(
            '$count',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Text(
            valueText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentItemRow(AssessmentItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(item.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),

          // Competency level selector
          _buildCompetencySelector(item),
        ],
      ),
    );
  }

  Widget _buildCompetencySelector(AssessmentItem item) {
    bool isPositive =
        item.competencyLevel == 'Competent' ||
        item.competencyLevel == 'Positive';
    bool hasSelection =
        item.competencyLevel != '' &&
        item.competencyLevel != 'Not Yet Competent';

    // This matches the screenshot with competency levels
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                _buildCompetencyOption(
                  'Not Yet Competent',
                  item.competencyLevel == 'Not Yet Competent',
                  item,
                ),
                _buildCompetencyOption(
                  'Skill gap',
                  item.competencyLevel == 'Skill gap',
                  item,
                ),
                _buildCompetencyOption(
                  'Knowledge Gap',
                  item.competencyLevel == 'Knowledge Gap',
                  item,
                ),
                _buildCompetencyOption(
                  'Competent',
                  item.competencyLevel == 'Competent',
                  item,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            // Toggle between Competent and Not Yet Competent when clicking the checkmark
            setState(() {
              if (item.title == 'Attitude') {
                item.competencyLevel =
                    (item.competencyLevel == 'Positive')
                        ? 'Not Yet Competent'
                        : 'Positive';
              } else {
                item.competencyLevel =
                    (item.competencyLevel == 'Competent')
                        ? 'Not Yet Competent'
                        : 'Competent';
              }
              // Update score
              _updateAssessmentScore();

              // Show feedback
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Assessment marked as: ${item.competencyLevel}',
                  ),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  !hasSelection
                      ? Colors.grey.shade300
                      : (isPositive ? Colors.green : Colors.amber),
              shape: BoxShape.circle,
            ),
            child: Icon(
              !hasSelection
                  ? Icons.circle_outlined
                  : (isPositive ? Icons.check : Icons.pending),
              color: !hasSelection ? Colors.grey.shade600 : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompetencyOption(
    String label,
    bool isSelected,
    AssessmentItem item,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          // Update the competency level directly in the AssessmentItem
          setState(() {
            // This will trigger a rebuild with the new selection
            if (item.competencyLevel != label) {
              item.competencyLevel = label;
              // Update the score whenever competency changes
              _updateAssessmentScore();

              // Show feedback for selection
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Assessment marked as: $label'),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            // Use blue for selected option, grey for unselected
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            border: Border(right: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // For the attitude row, we need a special widget
  Widget _buildAttitudeRow(AssessmentItem item) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                _buildCompetencyOption(
                  'Negative',
                  item.competencyLevel == 'Negative',
                  item,
                ),
                _buildCompetencyOption(
                  'Lacks attention',
                  item.competencyLevel == 'Lacks attention',
                  item,
                ),
                _buildCompetencyOption(
                  'Positive',
                  item.competencyLevel == 'Positive',
                  item,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white),
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
