import 'package:flutter/material.dart';
import '../../widgets/modern_layout.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernLayout(
      title: 'My Grades',
      currentIndex: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPerformanceOverview(),
            const SizedBox(height: 24),
            const Text(
              'Course Grades',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildCourseGradeCard(
                    courseName: 'Flutter Development Masterclass',
                    courseImage:
                        'lib/assets/images/courses/course_1_thumbnail.jpg',
                    grade: 'A',
                    percentage: 92,
                    assessments: [
                      GradeItem(
                        title: 'Module 1 Quiz',
                        grade: 'A',
                        score: '9/10',
                        date: 'Jan 15, 2023',
                      ),
                      GradeItem(
                        title: 'Module 2 Quiz',
                        grade: 'A+',
                        score: '10/10',
                        date: 'Jan 22, 2023',
                      ),
                      GradeItem(
                        title: 'UI Building Exercise',
                        grade: 'A-',
                        score: '88/100',
                        date: 'Jan 28, 2023',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCourseGradeCard(
                    courseName: 'Python for Data Science',
                    courseImage:
                        'lib/assets/images/courses/course_2_thumbnail.jpg',
                    grade: 'B+',
                    percentage: 88,
                    assessments: [
                      GradeItem(
                        title: 'Python Basics Quiz',
                        grade: 'A',
                        score: '18/20',
                        date: 'Feb 5, 2023',
                      ),
                      GradeItem(
                        title: 'Data Analysis Project',
                        grade: 'B',
                        score: '85/100',
                        date: 'Feb 18, 2023',
                      ),
                      GradeItem(
                        title: 'Data Visualization Assignment',
                        grade: 'B+',
                        score: '42/50',
                        date: 'Mar 2, 2023',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCourseGradeCard(
                    courseName: 'Web Development with React',
                    courseImage:
                        'lib/assets/images/courses/course_3_thumbnail.jpg',
                    grade: 'A-',
                    percentage: 90,
                    assessments: [
                      GradeItem(
                        title: 'JavaScript Fundamentals Quiz',
                        grade: 'A-',
                        score: '17/20',
                        date: 'Mar 10, 2023',
                      ),
                      GradeItem(
                        title: 'React Component Challenge',
                        grade: 'A',
                        score: '48/50',
                        date: 'Mar 22, 2023',
                      ),
                      GradeItem(
                        title: 'Single Page Application Project',
                        grade: 'A-',
                        score: '91/100',
                        date: 'Apr 8, 2023',
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

  Widget _buildPerformanceOverview() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('A-', 'Overall GPA', Colors.blue),
                _buildStatItem('90%', 'Average Score', Colors.green),
                _buildStatItem('12', 'Assessments', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Grade Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildGradeBar('A', 0.6, Colors.green),
                const SizedBox(width: 8),
                _buildGradeBar('B', 0.3, Colors.blue),
                const SizedBox(width: 8),
                _buildGradeBar('C', 0.1, Colors.orange),
                const SizedBox(width: 8),
                _buildGradeBar('D', 0.0, Colors.red),
                const SizedBox(width: 8),
                _buildGradeBar('F', 0.0, Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildGradeBar(String grade, double percentage, Color color) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 80 * percentage,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            grade,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: percentage > 0 ? color : Colors.grey[600],
            ),
          ),
          Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseGradeCard({
    required String courseName,
    required String courseImage,
    required String grade,
    required int percentage,
    required List<GradeItem> assessments,
  }) {
    // Determine grade color
    Color gradeColor;
    if (grade.startsWith('A')) {
      gradeColor = Colors.green;
    } else if (grade.startsWith('B')) {
      gradeColor = Colors.blue;
    } else if (grade.startsWith('C')) {
      gradeColor = Colors.orange;
    } else if (grade.startsWith('D')) {
      gradeColor = Colors.orange[700]!;
    } else {
      gradeColor = Colors.red;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          courseName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Overall grade: $grade · $percentage%',
          style: TextStyle(color: Colors.grey[700]),
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: gradeColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              grade,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: gradeColor,
              ),
            ),
          ),
        ),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Assessment Grades',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ...assessments.map((assessment) => _buildAssessmentItem(assessment)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAssessmentItem(GradeItem item) {
    // Determine grade color
    Color gradeColor;
    if (item.grade.startsWith('A')) {
      gradeColor = Colors.green;
    } else if (item.grade.startsWith('B')) {
      gradeColor = Colors.blue;
    } else if (item.grade.startsWith('C')) {
      gradeColor = Colors.orange;
    } else if (item.grade.startsWith('D')) {
      gradeColor = Colors.orange[700]!;
    } else {
      gradeColor = Colors.red;
    }

    return ListTile(
      title: Text(
        item.title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'Date: ${item.date}',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.score,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                item.grade,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: gradeColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GradeItem {
  final String title;
  final String grade;
  final String score;
  final String date;

  GradeItem({
    required this.title,
    required this.grade,
    required this.score,
    required this.date,
  });
}
