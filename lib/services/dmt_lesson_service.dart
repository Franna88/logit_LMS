import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../screens/student/course_detail_screen.dart';

class DMTLessonService {
  static const String _lessonPlansPath = 'lib/assets/output/images/lessons.json';
  static const String _slidesPath = 'lib/assets/output/images/slides.json';
  static const String _modulesPath = 'lib/assets/output/images/modules.json';
  static const String _coursesPath = 'lib/assets/output/images/courses.json';

  // Cache for loaded data
  static List<Map<String, dynamic>>? _cachedLessons;
  static List<Map<String, dynamic>>? _cachedSlides;
  static List<Map<String, dynamic>>? _cachedModules;
  static List<Map<String, dynamic>>? _cachedCourses;

  /// Load all lessons from the assets
  static Future<List<Map<String, dynamic>>> loadLessons() async {
    if (_cachedLessons != null) return _cachedLessons!;

    try {
      final String jsonString = await rootBundle.loadString(_lessonPlansPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedLessons = jsonList.cast<Map<String, dynamic>>();
      return _cachedLessons!;
    } catch (e) {
      debugPrint('Error loading lessons: $e');
      return [];
    }
  }

  /// Load all slides from the assets
  static Future<List<Map<String, dynamic>>> loadSlides() async {
    if (_cachedSlides != null) return _cachedSlides!;

    try {
      final String jsonString = await rootBundle.loadString(_slidesPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedSlides = jsonList.cast<Map<String, dynamic>>();
      return _cachedSlides!;
    } catch (e) {
      debugPrint('Error loading slides: $e');
      return [];
    }
  }

  /// Load all modules from the assets
  static Future<List<Map<String, dynamic>>> loadModules() async {
    if (_cachedModules != null) return _cachedModules!;

    try {
      final String jsonString = await rootBundle.loadString(_modulesPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedModules = jsonList.cast<Map<String, dynamic>>();
      return _cachedModules!;
    } catch (e) {
      debugPrint('Error loading modules: $e');
      return [];
    }
  }

  /// Load all courses from the assets
  static Future<List<Map<String, dynamic>>> loadCourses() async {
    if (_cachedCourses != null) return _cachedCourses!;

    try {
      final String jsonString = await rootBundle.loadString(_coursesPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedCourses = jsonList.cast<Map<String, dynamic>>();
      return _cachedCourses!;
    } catch (e) {
      debugPrint('Error loading courses: $e');
      return [];
    }
  }

  /// Find the DMT course
  static Future<Map<String, dynamic>?> getDMTCourse() async {
    final courses = await loadCourses();
    debugPrint('DMTLessonService: Loaded ${courses.length} courses');
    
    for (var course in courses) {
      debugPrint('Course: ${course['title']}');
    }
    
    try {
      final dmtCourse = courses.firstWhere(
        (course) => course['title']?.toString().contains('DMT') ?? false,
      );
      debugPrint('DMTLessonService: Found DMT course: ${dmtCourse['title']}');
      return dmtCourse;
    } catch (e) {
      debugPrint('DMTLessonService: No DMT course found');
      return null;
    }
  }

  /// Get modules for the DMT course
  static Future<List<Map<String, dynamic>>> getDMTModules() async {
    final dmtCourse = await getDMTCourse();
    if (dmtCourse == null || dmtCourse.isEmpty) return [];

    final courseId = dmtCourse['_id'];
    final modules = await loadModules();
    
    return modules
        .where((module) => module['courseId'] == courseId)
        .toList()
      ..sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
  }

  /// Get lessons for a specific module
  static Future<List<Map<String, dynamic>>> getLessonsForModule(String moduleId) async {
    final lessons = await loadLessons();
    return lessons
        .where((lesson) => lesson['moduleId'] == moduleId)
        .toList()
      ..sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
  }

  /// Get slides for a specific lesson
  static Future<List<Map<String, dynamic>>> getSlidesForLesson(String lessonId) async {
    final slides = await loadSlides();
    return slides
        .where((slide) => slide['lessonId'] == lessonId)
        .toList()
      ..sort((a, b) => (a['slideNumber'] ?? 0).compareTo(b['slideNumber'] ?? 0));
  }

  /// Get a specific lesson by ID
  static Future<Map<String, dynamic>?> getLessonById(String lessonId) async {
    final lessons = await loadLessons();
    try {
      return lessons.firstWhere((lesson) => lesson['_id'] == lessonId);
    } catch (e) {
      return null;
    }
  }

  /// Convert lesson data to ContentItem objects for the course detail screen
  static Future<List<ContentItem>> convertLessonToContentItems(Map<String, dynamic> lessonData) async {
    List<ContentItem> contentItems = [];

    // Add lesson plan overview as first item
    contentItems.add(
      ContentItem(
        title: 'Lesson Plan: ${lessonData['title'] ?? 'Unknown'}',
        type: ContentType.introduction,
        duration: lessonData['duration'] ?? '50 min',
        isCompleted: false,
        additionalData: {
          'type': 'lesson_plan',
          'lesson_data': lessonData,
        },
      ),
    );

    // Get slides for this lesson
    final slides = await getSlidesForLesson(lessonData['_id']);

    // Convert each slide to a ContentItem
    for (var slide in slides) {
      final slideNumber = slide['slideNumber'] ?? 0;
      final title = _extractMainTitle(slide['title'] ?? '');

      contentItems.add(
        ContentItem(
          title: 'Slide $slideNumber: $title',
          type: ContentType.lesson,
          duration: '5 min',
          isCompleted: false,
          additionalData: {
            'type': 'slide',
            'slide_data': slide,
            'lesson_data': lessonData,
          },
        ),
      );
    }

    // Add assessment if available
    if (lessonData['assessment'] != null && (lessonData['assessment'] as List).isNotEmpty) {
      contentItems.add(
        ContentItem(
          title: 'Assessment',
          type: ContentType.assessment,
          duration: '10 min',
          isCompleted: false,
          additionalData: {
            'type': 'assessment',
            'assessment_data': lessonData['assessment'],
            'lesson_data': lessonData,
          },
        ),
      );
    }

    return contentItems;
  }

  /// Extract the main title from a slide title string (first line)
  static String _extractMainTitle(String fullTitle) {
    final parts = fullTitle.split('\n');
    if (parts.isNotEmpty) {
      return parts[0].trim();
    }
    return fullTitle;
  }

  /// Get all DMT content organized by modules
  static Future<List<DMTModuleData>> getDMTCourseContent() async {
    final modules = await getDMTModules();
    List<DMTModuleData> moduleDataList = [];

    for (var module in modules) {
      final lessons = await getLessonsForModule(module['_id']);
      List<ContentItem> allContentItems = [];

      for (var lesson in lessons) {
        final contentItems = await convertLessonToContentItems(lesson);
        allContentItems.addAll(contentItems);
      }

      moduleDataList.add(
        DMTModuleData(
          title: module['title'] ?? 'Unknown Module',
          description: module['description'] ?? '',
          contentItems: allContentItems,
          moduleData: module,
        ),
      );
    }

    return moduleDataList;
  }

  /// Clear cached data (useful for development/testing)
  static void clearCache() {
    _cachedLessons = null;
    _cachedSlides = null;
    _cachedModules = null;
    _cachedCourses = null;
  }
}

/// Data class to hold module information
class DMTModuleData {
  final String title;
  final String description;
  final List<ContentItem> contentItems;
  final Map<String, dynamic> moduleData;

  DMTModuleData({
    required this.title,
    required this.description,
    required this.contentItems,
    required this.moduleData,
  });

  /// Get completion statistics
  int get completedLessons => contentItems.where((item) => item.isCompleted).length;
  int get totalLessons => contentItems.length;
  double get progress => totalLessons > 0 ? completedLessons / totalLessons : 0.0;
  bool get isCompleted => progress >= 1.0;
}
