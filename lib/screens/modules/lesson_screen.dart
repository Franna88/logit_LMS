import 'package:flutter/material.dart';
import '../../widgets/modern_layout.dart';

class LessonScreen extends StatefulWidget {
  final String moduleTitle;
  final String lessonTitle;
  final String lessonContent;
  final List<String>? imageUrls;
  final bool isCompleted;
  final VoidCallback onComplete;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool hasNext;
  final bool hasPrevious;

  const LessonScreen({
    super.key,
    required this.moduleTitle,
    required this.lessonTitle,
    required this.lessonContent,
    this.imageUrls,
    required this.isCompleted,
    required this.onComplete,
    required this.onNext,
    required this.onPrevious,
    required this.hasNext,
    required this.hasPrevious,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late ScrollController _scrollController;
  bool _showCompleteButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Show the complete button when user scrolls near the bottom
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_showCompleteButton) {
      setState(() {
        _showCompleteButton = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernLayout(
      title: widget.moduleTitle,
      showBackButton: true,
      currentIndex: -1,
      child: Stack(
        children: [
          // Lesson Content
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lesson Title
                Text(
                  widget.lessonTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Display images if available
                if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty)
                  _buildImageSection(widget.imageUrls!),

                // Lesson Content Text
                _buildContentText(widget.lessonContent),

                // Bottom padding to ensure content isn't hidden behind the navigation bar
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(List<String> imageUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (String imageUrl in imageUrls)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildContentText(String content) {
    // Split the content by paragraphs for better presentation
    final paragraphs = content.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          paragraphs.map((paragraph) => _formatParagraph(paragraph)).toList(),
    );
  }

  Widget _formatParagraph(String paragraph) {
    // Check if this is a heading (starts with # or ##)
    if (paragraph.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
        child: Text(
          paragraph.substring(3),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      );
    } else if (paragraph.startsWith('# ')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0, top: 12.0),
        child: Text(
          paragraph.substring(2),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      );
    }
    // Check if this is a list (starts with numbers or dashes)
    else if (paragraph.contains('\n1. ') ||
        paragraph.contains('\n- ') ||
        paragraph.startsWith('1. ') ||
        paragraph.startsWith('- ')) {
      // Split into list items
      final lines = paragraph.split('\n');
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              lines.map((line) {
                if (line.startsWith('- ') ||
                    line.startsWith('1. ') ||
                    line.startsWith('2. ') ||
                    line.startsWith('3. ') ||
                    line.startsWith('4. ') ||
                    line.startsWith('5. ')) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5, right: 8),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            line.startsWith('- ')
                                ? line.substring(2)
                                : line.substring(3),
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      line,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  );
                }
              }).toList(),
        ),
      );
    }
    // Regular paragraph
    else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(
          paragraph,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      );
    }
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          ElevatedButton.icon(
            onPressed: widget.hasPrevious ? widget.onPrevious : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue,
              backgroundColor: Colors.white,
              elevation: 0,
              disabledForegroundColor: Colors.grey.withOpacity(0.38),
              disabledBackgroundColor: Colors.grey.withOpacity(0.12),
            ),
          ),

          // Complete/Mark as Read Button (only shown when scrolled or already completed)
          if (_showCompleteButton || widget.isCompleted)
            ElevatedButton.icon(
              onPressed: widget.isCompleted ? null : widget.onComplete,
              icon: Icon(widget.isCompleted ? Icons.check_circle : Icons.check),
              label: Text(
                widget.isCompleted ? 'Completed' : 'Mark as Complete',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : Colors.green,
                foregroundColor:
                    widget.isCompleted ? Colors.green : Colors.white,
                disabledBackgroundColor: Colors.green.withOpacity(0.2),
                disabledForegroundColor: Colors.green,
              ),
            ),

          // Next Button
          ElevatedButton.icon(
            onPressed: widget.hasNext ? widget.onNext : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              disabledForegroundColor: Colors.grey.withOpacity(0.38),
              disabledBackgroundColor: Colors.grey.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }
}
