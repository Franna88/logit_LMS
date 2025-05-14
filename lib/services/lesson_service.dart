import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../screens/student/course_detail_screen.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetch all lessons from a course
  Future<List<ContentItem>> getLessonsForCourse(String courseId) async {
    debugPrint('Fetching lessons for course: $courseId');
    try {
      // Get course document
      final courseDoc =
          await _firestore.collection('courses').doc(courseId).get();

      if (!courseDoc.exists) {
        debugPrint('Course $courseId not found');
        return [];
      }

      debugPrint('Found course document: ${courseDoc.id}');

      // Get the lessons collection for this course
      final lessonsSnapshot =
          await _firestore
              .collection('courses')
              .doc(courseId)
              .collection('lessons')
              .orderBy('order')
              .get();

      debugPrint('Found ${lessonsSnapshot.docs.length} lessons in Firestore');

      List<ContentItem> contentItems = [];

      // Process each lesson
      for (var lessonDoc in lessonsSnapshot.docs) {
        final lessonId = lessonDoc.id;
        final lessonData = lessonDoc.data();

        debugPrint('Processing lesson: $lessonId');

        // Get the full lesson with slides
        final fullLessonData = await getLessonById(lessonId);

        if (fullLessonData != null) {
          final title = lessonData['title'] ?? 'Untitled Lesson';
          final duration = lessonData['duration'] ?? '5 min';
          final isCompleted = lessonData['isCompleted'] ?? false;

          debugPrint('Adding content item: $title');

          contentItems.add(
            ContentItem(
              title: title,
              type: ContentType.lesson,
              duration: duration,
              isCompleted: isCompleted,
              additionalData: fullLessonData,
            ),
          );
        } else {
          debugPrint('Failed to get full lesson data for $lessonId');
        }
      }

      debugPrint('Returning ${contentItems.length} content items');
      return contentItems;
    } catch (e) {
      debugPrint('Error fetching lessons for course: $e');
      return [];
    }
  }

  // Generate a Firebase Storage URL with token (valid for 1 hour)
  Future<String> getStorageUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      // Get download URL that works in all environments including web
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error getting storage URL for $path: $e');
      // Return a placeholder image URL if there's an error
      return 'https://via.placeholder.com/400x300?text=Image+Not+Available';
    }
  }

  // Fetch a specific lesson by ID
  Future<Map<String, dynamic>?> getLessonById(String lessonId) async {
    debugPrint('Fetching lesson by ID: $lessonId');
    try {
      final lessonDoc =
          await _firestore.collection('lessons').doc(lessonId).get();

      if (!lessonDoc.exists) {
        debugPrint('Lesson $lessonId not found');
        return null;
      }

      debugPrint('Found lesson document: ${lessonDoc.id}');

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

      debugPrint(
        'Found ${slidesSnapshot.docs.length} slides for lesson $lessonId',
      );

      // Process the slides
      final List<Map<String, dynamic>> slides = [];

      for (var slideDoc in slidesSnapshot.docs) {
        final slideData = slideDoc.data();
        final slideNumber = slideData['slideNumber'];
        debugPrint('Processing slide $slideNumber');

        // Ensure slide data has the necessary fields
        if (slideData.containsKey('slideNumber') &&
            slideData.containsKey('title')) {
          // Process image URLs if present
          if (slideData.containsKey('images') && slideData['images'] is List) {
            final List<dynamic> imagesList = slideData['images'] as List;
            debugPrint(
              'Processing ${imagesList.length} images in slide $slideNumber',
            );

            final List<dynamic> processedImages = [];
            for (var image in imagesList) {
              if (image is Map<String, dynamic>) {
                final Map<String, dynamic> processedImage = {...image};

                // Process the URL if it's a Firebase Storage path
                if (image.containsKey('url')) {
                  final String url = image['url'];
                  debugPrint('Processing image URL: $url');

                  if (url.startsWith('gs://') || url.startsWith('lessons/')) {
                    // This is a Firebase Storage path, get the download URL
                    try {
                      debugPrint('Getting Firebase Storage URL for: $url');
                      final downloadUrl = await getStorageUrl(url);
                      processedImage['url'] = downloadUrl;
                      debugPrint('Got download URL: $downloadUrl');
                    } catch (e) {
                      debugPrint('Error processing image URL: $e');
                    }
                  }
                }

                processedImages.add(processedImage);
              }
            }
            // Replace the images list with processed ones
            slideData['images'] = processedImages;
          }

          slides.add(slideData);
        } else {
          debugPrint('Slide missing required fields: slideNumber or title');
        }
      }

      // Add the slides to the lesson data
      lessonData['slides'] = slides;

      debugPrint('Returning lesson data with ${slides.length} slides');
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

  // Get lessons for a specific course
  Future<List<ContentItem>> getLessonsForCourseId(String courseId) async {
    return await getLessonsForCourse(courseId);
  }

  // Create sample data in Firebase if none exists
  Future<void> createSampleDataIfNeeded() async {
    debugPrint('Checking if sample data needs to be created...');

    try {
      // Check if default course exists
      final defaultCourseId = "diving_safety_course";
      final courseDoc =
          await _firestore.collection('courses').doc(defaultCourseId).get();

      if (courseDoc.exists) {
        debugPrint(
          'Sample course already exists. No need to create sample data.',
        );
        return;
      }

      debugPrint('Creating sample course and lessons in Firebase...');

      // Create course
      await _firestore.collection('courses').doc(defaultCourseId).set({
        'title': 'Diving Safety and Awareness',
        'description':
            'Learn essential diving safety techniques and protocols.',
        'duration': '7 weeks',
        'instructor': 'Mark Anderson',
        'imageUrl': 'lib/assets/images/course.jpg', // Local image path
        'createdAt': Timestamp.now(),
      });

      // Create lessons collection for the course

      // Create first lesson document
      final lesson1Id = "diving_safety_lesson_01";
      await _firestore
          .collection('courses')
          .doc(defaultCourseId)
          .collection('lessons')
          .doc(lesson1Id)
          .set({
            'title': 'Introduction to Diving Safety',
            'description': 'Basic principles of diving safety.',
            'duration': '45 min',
            'order': 1,
            'isCompleted': false,
          });

      // Create the actual lesson document
      await _firestore.collection('lessons').doc(lesson1Id).set({
        'title': 'Introduction to Diving Safety',
        'description': 'Basic principles of diving safety.',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Create slides for lesson 1
      await _firestore
          .collection('lessons')
          .doc(lesson1Id)
          .collection('slides')
          .doc('slide_01')
          .set({
            'slideNumber': 1,
            'title':
                'Introduction to Diving Safety\nBasic Principles and Practices',
            'content':
                'Diving safety is the foundation of a successful and enjoyable diving experience. This lesson introduces the fundamental safety principles every diver should know.',
            'images': [
              {
                'url':
                    'https://cdn.pixabay.com/photo/2016/05/24/14/04/scuba-diving-1412428_1280.jpg',
                'description': 'Diver with proper safety equipment',
              },
            ],
          });

      await _firestore
          .collection('lessons')
          .doc(lesson1Id)
          .collection('slides')
          .doc('slide_02')
          .set({
            'slideNumber': 2,
            'title': 'Pre-Dive Safety Checks',
            'content':
                'Always conduct a thorough pre-dive safety check with your buddy. This includes checking your equipment, verifying your air supply, and reviewing your dive plan.',
            'images': [
              {
                'url':
                    'https://cdn.pixabay.com/photo/2020/05/18/07/40/diving-5185257_1280.jpg',
                'description': 'Divers performing buddy check',
              },
            ],
          });

      // Create second lesson document
      final lesson2Id = "diving_safety_lesson_02";
      await _firestore
          .collection('courses')
          .doc(defaultCourseId)
          .collection('lessons')
          .doc(lesson2Id)
          .set({
            'title': 'Equipment Safety',
            'description': 'Learn about diving equipment safety features.',
            'duration': '60 min',
            'order': 2,
            'isCompleted': false,
          });

      // Create the actual lesson document
      await _firestore.collection('lessons').doc(lesson2Id).set({
        'title': 'Equipment Safety',
        'description': 'Learn about diving equipment safety features.',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Create slides for lesson 2
      await _firestore
          .collection('lessons')
          .doc(lesson2Id)
          .collection('slides')
          .doc('slide_01')
          .set({
            'slideNumber': 1,
            'title': 'Diving Equipment Safety\nMaintenance and Inspection',
            'content':
                'Proper maintenance and regular inspection of your diving equipment is essential for safety. This lesson covers key equipment safety practices.',
            'images': [
              {
                'url':
                    'https://cdn.pixabay.com/photo/2017/07/14/16/09/diving-2504276_1280.jpg',
                'description': 'Scuba equipment laid out for inspection',
              },
            ],
          });

      await _firestore
          .collection('lessons')
          .doc(lesson2Id)
          .collection('slides')
          .doc('slide_02')
          .set({
            'slideNumber': 2,
            'title': 'Regulator Safety',
            'content':
                'The regulator is your lifeline underwater. Learn how to properly maintain and inspect your regulator before each dive.',
            'images': [
              {
                'url':
                    'https://cdn.pixabay.com/photo/2016/11/22/19/25/adult-1850181_1280.jpg',
                'description': 'Diver using regulator',
              },
            ],
          });

      debugPrint('Sample data created successfully!');
    } catch (e) {
      debugPrint('Error creating sample data: $e');
    }
  }

  // Method for backward compatibility - will be removed in future
  Future<List<ContentItem>> getLesson01ContentItems() async {
    debugPrint('Getting first lesson from diving_safety_course...');
    // This is a temporary method for backward compatibility
    // It fetches the first lesson from the default course
    final defaultCourseId = "diving_safety_course";
    final lessons = await getLessonsForCourse(defaultCourseId);

    debugPrint('Found ${lessons.length} lessons for course $defaultCourseId');

    if (lessons.isNotEmpty) {
      debugPrint('Returning first lesson: ${lessons.first.title}');
      return [lessons.first];
    }

    debugPrint('No lessons found for course $defaultCourseId');
    // Return empty list if no lessons found
    return [];
  }

  // Method for backward compatibility - will be removed in future
  Future<List<ContentItem>> getLesson02ContentItems() async {
    debugPrint('Getting second lesson from diving_safety_course...');
    // This is a temporary method for backward compatibility
    // It fetches the second lesson from the default course
    final defaultCourseId = "diving_safety_course";
    final lessons = await getLessonsForCourse(defaultCourseId);

    debugPrint('Found ${lessons.length} lessons for course $defaultCourseId');

    if (lessons.length >= 2) {
      debugPrint('Returning second lesson: ${lessons[1].title}');
      return [lessons[1]];
    }

    debugPrint('No second lesson found for course $defaultCourseId');
    // Return empty list if no second lesson found
    return [];
  }
}
