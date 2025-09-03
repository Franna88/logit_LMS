import 'package:flutter/material.dart';
import 'lesson_plan_screen.dart';
import 'lesson_screen.dart';

class ComprehensiveLessonScreen extends StatefulWidget {
  final String moduleTitle;
  final String lessonTitle;
  final Map<String, dynamic> lessonData;

  const ComprehensiveLessonScreen({
    super.key,
    required this.moduleTitle,
    required this.lessonTitle,
    required this.lessonData,
  });

  @override
  State<ComprehensiveLessonScreen> createState() => _ComprehensiveLessonScreenState();
}

class _ComprehensiveLessonScreenState extends State<ComprehensiveLessonScreen> {
  int _currentIndex = 0; // 0 = lesson plan, 1+ = lesson slides
  bool _lessonPlanCompleted = false;
  List<Map<String, dynamic>> _slides = [];

  @override
  void initState() {
    super.initState();
    _loadSlides();
  }

  void _loadSlides() {
    // Extract slides from lesson data
    if (widget.lessonData.containsKey('slideContent')) {
      final slideContent = widget.lessonData['slideContent'] as Map<String, dynamic>;
      if (slideContent.containsKey('slides')) {
        _slides = List<Map<String, dynamic>>.from(slideContent['slides']);
      }
    }
    
    // If no slide content, use the slides from the lesson plan itself
    if (_slides.isEmpty && widget.lessonData.containsKey('slides')) {
      _slides = List<Map<String, dynamic>>.from(widget.lessonData['slides']);
    }

    debugPrint('ComprehensiveLessonScreen: Loaded ${_slides.length} slides');
  }

  void _navigateNext() {
    if (_currentIndex == 0) {
      // Moving from lesson plan to first slide
      setState(() {
        _lessonPlanCompleted = true;
        _currentIndex = 1;
      });
    } else if (_currentIndex < _slides.length) {
      // Moving to next slide
      setState(() {
        _currentIndex++;
      });
    } else {
      // Finished all slides, return to course
      Navigator.pop(context);
    }
  }

  void _navigatePrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    } else {
      // Return to course from lesson plan
      Navigator.pop(context);
    }
  }

  void _markComplete() {
    if (_currentIndex == 0) {
      setState(() {
        _lessonPlanCompleted = true;
      });
    }
    // Auto-navigate to next after a brief delay
    Future.delayed(const Duration(milliseconds: 500), _navigateNext);
  }

  @override
  Widget build(BuildContext context) {
    // Show lesson plan first
    if (_currentIndex == 0) {
      return LessonPlanScreen(
        moduleTitle: widget.moduleTitle,
        lessonTitle: widget.lessonTitle,
        lessonData: widget.lessonData,
        isCompleted: _lessonPlanCompleted,
        onComplete: _markComplete,
        onNext: _navigateNext,
        onPrevious: _navigatePrevious,
        hasNext: _slides.isNotEmpty,
        hasPrevious: true,
      );
    }

    // Show lesson slides
    final slideIndex = _currentIndex - 1;
    if (slideIndex < _slides.length) {
      final currentSlide = _slides[slideIndex];
      
      return LessonScreen(
        moduleTitle: widget.moduleTitle,
        lessonTitle: 'Slide ${slideIndex + 1}: ${_extractSlideTitle(currentSlide)}',
        lessonContent: _formatSlideContent(currentSlide),
        imageUrls: _getSlideImages(currentSlide),
        slideData: currentSlide,
        isCompleted: false,
        onComplete: _markComplete,
        onNext: _navigateNext,
        onPrevious: _navigatePrevious,
        hasNext: slideIndex < _slides.length - 1,
        hasPrevious: true,
      );
    }

    // Fallback - should not reach here
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Lesson Completed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Great job completing this lesson.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _extractSlideTitle(Map<String, dynamic> slide) {
    final title = slide['title']?.toString() ?? '';
    // Extract first line as the main title
    final lines = title.split('\n');
    if (lines.isNotEmpty) {
      return lines[0].trim();
    }
    return 'Lesson Content';
  }

  String _formatSlideContent(Map<String, dynamic> slide) {
    final title = slide['title']?.toString() ?? '';
    final content = slide['content'] as List<dynamic>? ?? [];
    
    String formattedContent = title;
    
    if (content.isNotEmpty) {
      formattedContent += '\n\nKey Points:\n';
      for (var item in content) {
        formattedContent += '• ${item.toString()}\n';
      }
    }
    
    return formattedContent;
  }

  List<String>? _getSlideImages(Map<String, dynamic> slide) {
    final images = slide['images'] as List<dynamic>? ?? [];
    if (images.isEmpty) return null;
    
    return images
        .map((img) => img['path']?.toString() ?? img['filename']?.toString() ?? '')
        .where((path) => path.isNotEmpty)
        .map((path) => path.startsWith('lib/assets/') ? path : 'lib/assets/$path')
        .toList();
  }
}
