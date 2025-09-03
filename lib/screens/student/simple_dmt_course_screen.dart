import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../widgets/modern_layout.dart';
import '../modules/comprehensive_lesson_screen.dart';

class SimpleDMTCourseScreen extends StatefulWidget {
  const SimpleDMTCourseScreen({super.key});

  @override
  State<SimpleDMTCourseScreen> createState() => _SimpleDMTCourseScreenState();
}

class _SimpleDMTCourseScreenState extends State<SimpleDMTCourseScreen> {
  List<Map<String, dynamic>> lessonPlans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessonPlans();
  }

  Future<void> _loadLessonPlans() async {
    try {
      // Load lesson plans directly from our extracted files
      final lessonPlanFiles = [
        'extracted_lesson_plans/lesson_plan_01.json',
        'extracted_lesson_plans/lesson_plan_02.json',
        'extracted_lesson_plans/lesson_plan_03.json',
        'extracted_lesson_plans/lesson_plan_04.json',
        'extracted_lesson_plans/lesson_plan_05.json',
        'extracted_lesson_plans/lesson_plan_06.json',
        'extracted_lesson_plans/lesson_plan_07.json',
        'extracted_lesson_plans/lesson_plan_08.json',
        'extracted_lesson_plans/lesson_plan_09.json',
        'extracted_lesson_plans/lesson_plan_10.json',
        'extracted_lesson_plans/lesson_plan_11.json',
        'extracted_lesson_plans/lesson_plan_12.json',
      ];

      // Also load the original slide-based lessons from output folder
      final originalLessons = [
        'output/Lesson_01.json',
        'output/Lesson_02.json',
      ];

      List<Map<String, dynamic>> loadedPlans = [];

      for (int i = 0; i < lessonPlanFiles.length; i++) {
        try {
          final String jsonString = await rootBundle.loadString(lessonPlanFiles[i]);
          final Map<String, dynamic> lessonPlan = json.decode(jsonString);
          
          // Try to load corresponding slide content if available
          if (i < originalLessons.length) {
            try {
              final String slideJsonString = await rootBundle.loadString(originalLessons[i]);
              final Map<String, dynamic> slideData = json.decode(slideJsonString);
              lessonPlan['slideContent'] = slideData; // Add slide content to lesson plan
            } catch (e) {
              debugPrint('No slide content found for lesson ${i + 1}: $e');
            }
          }
          
          loadedPlans.add(lessonPlan);
        } catch (e) {
          debugPrint('Error loading ${lessonPlanFiles[i]}: $e');
        }
      }

      setState(() {
        lessonPlans = loadedPlans;
        isLoading = false;
      });

      debugPrint('Loaded ${lessonPlans.length} lesson plans');
    } catch (e) {
      debugPrint('Error loading lesson plans: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernLayout(
      title: 'DMT Course - Lesson Plans',
      currentIndex: -1,
      showBackButton: true,
      child: Column(
        children: [
          // Course Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Diver Medic Training (DMT)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete Course with ${lessonPlans.length} Lesson Plans',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Target Audience: DMTs and MFAs',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading lesson plans...'),
                      ],
                    ),
                  )
                : lessonPlans.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red),
                            SizedBox(height: 16),
                            Text(
                              'No lesson plans found',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              'Please check the asset configuration',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : _buildLessonPlansList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonPlansList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessonPlans.length,
      itemBuilder: (context, index) {
        final lessonPlan = lessonPlans[index];
        final lessonNumber = lessonPlan['lesson_number'] ?? (index + 1);
        final title = lessonPlan['title'] ?? 'Lesson Plan ${index + 1}';
        final duration = lessonPlan['duration'] ?? '50 min';
        final objectivesCount = (lessonPlan['objectives'] as List?)?.length ?? 0;
        final slidesCount = (lessonPlan['slides'] as List?)?.length ?? 0;
        final hasSlideContent = lessonPlan.containsKey('slideContent');
        final actualSlidesCount = hasSlideContent 
            ? ((lessonPlan['slideContent'] as Map<String, dynamic>)['slides'] as List?)?.length ?? 0
            : slidesCount;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                lessonNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
                const SizedBox(height: 4),
                Text(
                  'Duration: $duration',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$objectivesCount objectives • $actualSlidesCount slides',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (hasSlideContent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Interactive',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (lessonPlan['target_audience'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Target: ${lessonPlan['target_audience']}',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openLessonPlan(lessonPlan, title),
          ),
        );
      },
    );
  }

  void _openLessonPlan(Map<String, dynamic> lessonPlan, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComprehensiveLessonScreen(
          moduleTitle: 'DMT Training',
          lessonTitle: title,
          lessonData: lessonPlan,
        ),
      ),
    );
  }
}
