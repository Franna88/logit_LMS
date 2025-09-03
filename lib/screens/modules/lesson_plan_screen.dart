import 'package:flutter/material.dart';

class LessonPlanScreen extends StatefulWidget {
  final String moduleTitle;
  final String lessonTitle;
  final Map<String, dynamic> lessonData;
  final bool isCompleted;
  final VoidCallback onComplete;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool hasNext;
  final bool hasPrevious;

  const LessonPlanScreen({
    super.key,
    required this.moduleTitle,
    required this.lessonTitle,
    required this.lessonData,
    required this.isCompleted,
    required this.onComplete,
    required this.onNext,
    required this.onPrevious,
    required this.hasNext,
    required this.hasPrevious,
  });

  @override
  State<LessonPlanScreen> createState() => _LessonPlanScreenState();
}

class _LessonPlanScreenState extends State<LessonPlanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          widget.moduleTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Lesson Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.lessonData['title'] ?? 'Lesson Plan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.lessonData['duration'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Duration: ${widget.lessonData['duration']}',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (widget.lessonData['description'] != null)
                    _buildSection(
                      'Overview',
                      widget.lessonData['description'],
                      Icons.info_outline,
                    ),

                  // Target Audience
                  if (widget.lessonData['target_audience'] != null)
                    _buildSection(
                      'Target Audience',
                      widget.lessonData['target_audience'],
                      Icons.group,
                    ),

                  // Learning Objectives
                  if (widget.lessonData['objectives'] != null)
                    _buildListSection(
                      'Learning Objectives',
                      widget.lessonData['objectives'],
                      Icons.school,
                    ),

                  // Materials Required
                  if (widget.lessonData['materials'] != null)
                    _buildListSection(
                      'Materials Required',
                      widget.lessonData['materials'],
                      Icons.inventory,
                    ),

                  // Activities
                  if (widget.lessonData['activities'] != null)
                    _buildListSection(
                      'Lesson Activities',
                      widget.lessonData['activities'],
                      Icons.assignment,
                    ),

                  // Assessment Criteria
                  if (widget.lessonData['assessment'] != null)
                    _buildAssessmentSection(),

                  const SizedBox(height: 20),

                  // Ready to Start Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.play_circle_outline, color: Colors.green, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Ready to Start the Lesson?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Review the lesson plan above, then proceed to the interactive lesson content.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation buttons
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
                if (widget.hasPrevious)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onPrevious,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (widget.hasPrevious && widget.hasNext) const SizedBox(width: 16),
                if (widget.hasNext)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!widget.isCompleted) {
                          widget.onComplete();
                        }
                        widget.onNext();
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Start Lesson'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(String title, List<dynamic> items, IconData icon) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.asMap().entries.map((entry) {
              final item = entry.value.toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentSection() {
    final assessments = widget.lessonData['assessment'] as List<dynamic>;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assessment, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Assessment Criteria',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...assessments.map((assessment) {
              if (assessment is Map<String, dynamic>) {
                final grade = assessment['grade']?.toString() ?? '';
                final criteria = assessment['criteria']?.toString() ?? '';
                
                Color gradeColor;
                switch (grade.toLowerCase()) {
                  case 'green':
                    gradeColor = Colors.green;
                    break;
                  case 'amber':
                    gradeColor = Colors.orange;
                    break;
                  case 'red':
                    gradeColor = Colors.red;
                    break;
                  default:
                    gradeColor = Colors.grey;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2, right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: gradeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          grade,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          criteria,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ],
        ),
      ),
    );
  }
}
