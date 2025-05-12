import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String imageUrl;
  final String courseName;
  final String courseDescription;
  final String authorName;
  final double rating;
  final int studentCount;
  final String status; // 'owned', 'free', or price
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.imageUrl,
    required this.courseName,
    required this.courseDescription,
    required this.authorName,
    required this.rating,
    required this.studentCount,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child:
                  imageUrl.startsWith('http')
                      ? Image.network(
                        imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.blue[100],
                        child: Center(
                          child: Icon(
                            _getCourseIcon(),
                            size: 60,
                            color: Colors.blue,
                          ),
                        ),
                      ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Name
                  Text(
                    courseName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Course Description
                  Text(
                    courseDescription,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Author Info
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        authorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating and Student Count
                  Row(
                    children: [
                      _buildRating(rating),
                      const SizedBox(width: 16),
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$studentCount students',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Status (Owned, Free, or Price)
                  _buildStatusChip(status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRating(double rating) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return const Icon(Icons.star, size: 16, color: Colors.amber);
            } else if (index < rating.ceil() &&
                rating.truncateToDouble() != rating) {
              return const Icon(Icons.star_half, size: 16, color: Colors.amber);
            } else {
              return Icon(Icons.star_border, size: 16, color: Colors.grey[400]);
            }
          }),
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    if (status == 'owned') {
      backgroundColor = Colors.green[100]!;
      textColor = Colors.green[800]!;
      label = 'Owned';
    } else if (status == 'free') {
      backgroundColor = Colors.blue[100]!;
      textColor = Colors.blue[800]!;
      label = 'Free';
    } else {
      // It's a price
      backgroundColor = Colors.orange[100]!;
      textColor = Colors.orange[800]!;
      label = status; // The status itself contains the price
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  IconData _getCourseIcon() {
    // This could be more sophisticated, checking the course name or category
    if (courseName.toLowerCase().contains('flutter')) {
      return Icons.mobile_friendly;
    } else if (courseName.toLowerCase().contains('web')) {
      return Icons.web;
    } else if (courseName.toLowerCase().contains('design')) {
      return Icons.design_services;
    } else if (courseName.toLowerCase().contains('python')) {
      return Icons.code;
    } else if (courseName.toLowerCase().contains('data')) {
      return Icons.data_usage;
    } else {
      return Icons.school;
    }
  }
}
