import 'package:flutter/material.dart';
import 'dart:io';

class ModernCourseCard extends StatelessWidget {
  final String imageAsset; // Path to the image in assets directory
  final String courseName;
  final String courseDescription;
  final String authorName;
  final double rating;
  final int studentCount;
  final String status; // 'owned', 'free', or price
  final VoidCallback onTap;
  final VoidCallback? onMoreOptionsPressed;

  const ModernCourseCard({
    super.key,
    required this.imageAsset,
    required this.courseName,
    required this.courseDescription,
    required this.authorName,
    required this.rating,
    required this.studentCount,
    required this.status,
    required this.onTap,
    this.onMoreOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image with Gradient Overlay
            Stack(
              children: [
                SizedBox(
                  height: 120, // Reduced height
                  width: double.infinity,
                  child: _buildCourseImage(),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: onMoreOptionsPressed ?? () {},
                    iconSize: 20, // Smaller icon
                    padding: const EdgeInsets.all(4), // Smaller padding
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ), // Reduced padding
                    child: Text(
                      courseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16, // Smaller font
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: _buildStatusChip(status),
                ), // Adjusted position
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Description
                  Text(
                    courseDescription,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ), // Smaller font
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8), // Reduced spacing
                  // Author Info and Rating in a more compact layout
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10, // Smaller avatar
                        backgroundColor: Colors.blue[100],
                        backgroundImage:
                            imageAsset.contains('course')
                                ? AssetImage('lib/assets/images/profile.jpg')
                                : null,
                        child:
                            imageAsset.contains('course')
                                ? null
                                : Text(
                                  authorName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10, // Smaller font
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                      ),
                      const SizedBox(width: 6), // Reduced spacing
                      Expanded(
                        child: Text(
                          authorName,
                          style: const TextStyle(
                            fontSize: 13, // Smaller font
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6), // Reduced spacing
                  // Rating and Student Count
                  Row(
                    children: [
                      _buildRating(rating),
                      const SizedBox(width: 6), // Reduced spacing
                      Text(
                        rating.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 12), // Reduced spacing
                      Icon(
                        Icons.people,
                        size: 12,
                        color: Colors.grey[600],
                      ), // Smaller icon
                      const SizedBox(width: 2), // Reduced spacing
                      Text(
                        '$studentCount students',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildCourseImage() {
    if (imageAsset.isNotEmpty) {
      try {
        // Try to load image from assets
        if (imageAsset.startsWith('http')) {
          // If it's a URL, use Image.network
          return Image.network(
            imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderImage();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              );
            },
          );
        } else {
          // Load from assets
          return Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderImage();
            },
          );
        }
      } catch (e) {
        return _buildPlaceholderImage();
      }
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    // Generate a color based on the course name for variety
    final int hashCode = courseName.hashCode;
    final primaryColor = Colors.primaries[hashCode % Colors.primaries.length];
    final shadeColor = primaryColor[200]!;

    return Container(
      color: shadeColor,
      child: Center(
        child: Icon(
          _getCourseIcon(),
          size: 40,
          color: Colors.white,
        ), // Smaller icon
      ),
    );
  }

  IconData _getCourseIcon() {
    final lowerCaseName = courseName.toLowerCase();
    if (lowerCaseName.contains('flutter')) {
      return Icons.mobile_friendly;
    } else if (lowerCaseName.contains('web')) {
      return Icons.web;
    } else if (lowerCaseName.contains('design')) {
      return Icons.design_services;
    } else if (lowerCaseName.contains('python')) {
      return Icons.code;
    } else if (lowerCaseName.contains('data')) {
      return Icons.data_usage;
    } else {
      return Icons.school;
    }
  }

  Widget _buildRating(double rating) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return const Icon(Icons.star, size: 14, color: Colors.amber);
          } else if (index < rating.ceil() &&
              rating.truncateToDouble() != rating) {
            return const Icon(Icons.star_half, size: 14, color: Colors.amber);
          } else {
            return Icon(Icons.star_border, size: 14, color: Colors.grey[400]);
          }
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    String label = status;
    Color textColor = Colors.white;

    if (status == 'owned') {
      backgroundColor = Colors.green;
      label = 'Owned';
    } else if (status == 'free') {
      backgroundColor = Colors.blue;
      label = 'Free';
    } else {
      backgroundColor = Colors.orange;
      label = status; // Price as label
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10, // Smaller font
        ),
      ),
    );
  }
}
