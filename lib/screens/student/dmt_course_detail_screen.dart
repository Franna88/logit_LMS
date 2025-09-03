import 'package:flutter/material.dart';
import '../../widgets/modern_layout.dart';
import '../../screens/modules/content_navigator.dart';
import '../../services/dmt_lesson_service.dart';
import 'course_detail_screen.dart';

class DMTCourseDetailScreen extends StatefulWidget {
  const DMTCourseDetailScreen({super.key});

  @override
  State<DMTCourseDetailScreen> createState() => _DMTCourseDetailScreenState();
}

class _DMTCourseDetailScreenState extends State<DMTCourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = true;
  List<DMTModuleData> _dmtModules = [];
  Map<String, dynamic>? _dmtCourse;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDMTCourseData();
  }

  Future<void> _loadDMTCourseData() async {
    try {
      setState(() => _isLoading = true);
      
      debugPrint('DMTCourseDetailScreen: Starting to load DMT course data...');
      
      // Load DMT course and modules
      final course = await DMTLessonService.getDMTCourse();
      debugPrint('DMTCourseDetailScreen: Course loaded: ${course != null}');
      
      final modules = await DMTLessonService.getDMTCourseContent();
      debugPrint('DMTCourseDetailScreen: Modules loaded: ${modules.length}');
      
      setState(() {
        _dmtCourse = course;
        _dmtModules = modules;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading DMT course data: $e');
      setState(() => _isLoading = false);
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
      title: _dmtCourse?['title'] ?? 'Diver Medic Training (DMT)',
      currentIndex: -1,
      showBackButton: true,
      child: Column(
        children: [
          // Course Header
          _buildCourseHeader(),

          // Tabs
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
              ),
              indicatorWeight: 2,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: const [
                Tab(text: 'Modules', height: 36),
                Tab(text: 'Discussion', height: 36),
                Tab(text: 'Resources', height: 36),
                Tab(text: 'Assessment', height: 36),
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
                _buildAssessmentTab(),
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
          Text('Loading DMT course content...'),
        ],
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Course Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage('https://picsum.photos/id/1031/500/300'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Course Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      'Full Course',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person, color: Colors.white, size: 12),
                          SizedBox(width: 2),
                          Text(
                            'DMT/MFA',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Progress
                const Text(
                  'Your Progress',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _calculateOverallProgress(),
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(_calculateOverallProgress() * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_getCompletedModulesCount()} of ${_dmtModules.length} modules completed',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesTab() {
    if (_dmtModules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Loading DMT Modules...',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Debug: Course loaded: ${_dmtCourse != null}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDMTCourseData,
              child: const Text('Retry Loading'),
            ),
            const SizedBox(height: 16),
            // Show available lesson plans as fallback
            _buildFallbackLessonPlans(),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      children: _dmtModules.asMap().entries.map((entry) {
        final module = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _buildModuleCard(
            title: module.title,
            description: module.description,
            completedLessons: module.completedLessons,
            totalLessons: module.totalLessons,
            progress: module.progress,
            isCompleted: module.isCompleted,
            contentItems: module.contentItems,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String description,
    required int completedLessons,
    required int totalLessons,
    required double progress,
    required bool isCompleted,
    required List<ContentItem> contentItems,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.green : Colors.blue,
          child: Icon(
            isCompleted ? Icons.check : Icons.play_arrow,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.isNotEmpty)
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              '$completedLessons of $totalLessons lessons completed',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Colors.blue,
              ),
            ),
          ],
        ),
        children: contentItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: item.isCompleted ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getContentTypeIcon(item.type),
                size: 16,
                color: item.isCompleted ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${_getContentTypeLabel(item.type)} • ${item.duration}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            trailing: item.isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                : TextButton(
                    onPressed: () => _startContent(contentItems, index),
                    child: const Text('Start', style: TextStyle(fontSize: 12)),
                  ),
            onTap: () => _startContent(contentItems, index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDiscussionTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Discussion Forum',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            'Coming soon',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Course Resources',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            'Coming soon',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Course Assessment',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            'Complete all modules to unlock',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData _getContentTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.introduction:
        return Icons.info;
      case ContentType.lesson:
        return Icons.article;
      case ContentType.video:
        return Icons.play_circle;
      case ContentType.quiz:
        return Icons.quiz;
      case ContentType.assessment:
        return Icons.assignment;
      default:
        return Icons.article;
    }
  }

  String _getContentTypeLabel(ContentType type) {
    switch (type) {
      case ContentType.introduction:
        return 'Lesson Plan';
      case ContentType.lesson:
        return 'Lesson';
      case ContentType.video:
        return 'Video';
      case ContentType.quiz:
        return 'Quiz';
      case ContentType.assessment:
        return 'Assessment';
      default:
        return 'Content';
    }
  }

  void _startContent(List<ContentItem> contentItems, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentNavigator(
          moduleTitle: 'DMT Training',
          contentItems: contentItems,
          initialContentIndex: index,
          onContentComplete: (contentIndex, isCompleted) {
            // Update completion status
            setState(() {
              contentItems[contentIndex] = ContentItem(
                title: contentItems[contentIndex].title,
                type: contentItems[contentIndex].type,
                duration: contentItems[contentIndex].duration,
                isCompleted: isCompleted,
                additionalData: contentItems[contentIndex].additionalData,
              );
            });
          },
        ),
      ),
    );
  }

  double _calculateOverallProgress() {
    if (_dmtModules.isEmpty) return 0.0;
    
    final totalProgress = _dmtModules.fold<double>(
      0.0, 
      (sum, module) => sum + module.progress,
    );
    
    return totalProgress / _dmtModules.length;
  }

  int _getCompletedModulesCount() {
    return _dmtModules.where((module) => module.isCompleted).length;
  }

  Widget _buildFallbackLessonPlans() {
    // Show the 12 lesson plans we extracted as a fallback
    final lessonPlans = [
      'Lesson Plan 1: Accident Management (Principles, Bleeding, Soft tissue and Shock)',
      'Lesson Plan 2: Accident Management (Fractures, Crush Injuries, Chest Trauma)',
      'Lesson Plan 3: Accident Management (Burns, Electrical Injury and Poisoning)',
      'Lesson Plan 4: Casualty Assessment',
      'Lesson Plan 5: Management of Medical Emergencies',
      'Lesson Plan 6: Cannulation',
      'Lesson Plan 7: Urethral Catheterisation',
      'Lesson Plan 8: Airway Management',
      'Lesson Plan 9: Chest Drain -Thoracentesis',
      'Lesson Plan 10: Suturing',
      'Lesson Plan 11: Drug Administration',
      'Lesson Plan 12: DMAS',
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Lesson Plans (Fallback)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          ...lessonPlans.take(6).map((plan) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.article, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plan,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          )),
          if (lessonPlans.length > 6)
            Text(
              '... and ${lessonPlans.length - 6} more lesson plans',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
