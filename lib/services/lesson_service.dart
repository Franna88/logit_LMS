import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/student/course_detail_screen.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Specific lesson IDs for Lesson_01 and Lesson_02
  static const String lesson01Id = "LES_20250514005426_9db35c81-6661-4b90";
  static const String lesson02Id = "LES_20250514005500_90b1977f-fe0d-45df";

  // Fetch a specific lesson by ID
  Future<Map<String, dynamic>?> getLessonById(String lessonId) async {
    try {
      final lessonDoc =
          await _firestore.collection('lessons').doc(lessonId).get();

      if (!lessonDoc.exists) {
        debugPrint('Lesson $lessonId not found');
        return null;
      }

      // Get the lesson data
      final lessonData = lessonDoc.data() as Map<String, dynamic>;

      // Get all slides for this lesson
      final slidesSnapshot =
          await _firestore
              .collection('lessons')
              .doc(lessonId)
              .collection('slides')
              .orderBy('slideNumber')
              .get();

      // Process the slides
      final List<Map<String, dynamic>> slides = [];

      for (var slideDoc in slidesSnapshot.docs) {
        final slideData = slideDoc.data();

        // Ensure slide data has the necessary fields
        if (slideData.containsKey('slideNumber') &&
            slideData.containsKey('title')) {
          slides.add(slideData);
        }
      }

      // Add the slides to the lesson data
      lessonData['slides'] = slides;

      return lessonData;
    } catch (e) {
      debugPrint('Error fetching lesson: $e');
      return null;
    }
  }

  // Convert lesson data to ContentItem objects for the course detail screen
  List<ContentItem> convertLessonToContentItems(
    Map<String, dynamic> lessonData,
  ) {
    final List<ContentItem> contentItems = [];

    // Extract slides from lesson data
    final slides = lessonData['slides'] as List<dynamic>;

    // Each slide becomes a ContentItem
    for (var slide in slides) {
      final slideNumber = slide['slideNumber'];
      final title = _extractMainTitle(slide['title']);

      // Determine if the slide has images
      final hasImages =
          slide['images'] != null && (slide['images'] as List).isNotEmpty;

      contentItems.add(
        ContentItem(
          title: 'Slide $slideNumber: $title',
          type: hasImages ? ContentType.lesson : ContentType.lesson,
          duration: '5 min',
          isCompleted: false,
          // Store the full slide data for use in the lesson screen
          additionalData: slide,
        ),
      );
    }

    return contentItems;
  }

  // Extract the main title from a slide title string (first line)
  String _extractMainTitle(String fullTitle) {
    final parts = fullTitle.split('\n');
    if (parts.isNotEmpty) {
      return parts[0].trim();
    }
    return fullTitle;
  }

  // Get Lesson 01 content items
  Future<List<ContentItem>> getLesson01ContentItems() async {
    final lessonData = await getLessonById(lesson01Id);
    if (lessonData != null) {
      return convertLessonToContentItems(lessonData);
    }
    return [];
  }

  // Get Lesson 02 content items
  Future<List<ContentItem>> getLesson02ContentItems() async {
    final lessonData = await getLessonById(lesson02Id);
    if (lessonData != null) {
      return convertLessonToContentItems(lessonData);
    }
    return [];
  }
}
