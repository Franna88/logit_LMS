import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String duration;
  final String status;
  final List<Module> modules;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.duration,
    required this.status,
    required this.modules,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    List<Module> modules = [];
    if (json['modules'] != null) {
      modules = List<Module>.from(
        json['modules'].map((module) => Module.fromJson(module)),
      );
    }

    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      duration: json['duration'] ?? '',
      status: json['status'] ?? '',
      modules: modules,
    );
  }
}

class Module {
  final String id;
  final String title;
  final List<String> sectionIds;

  Module({required this.id, required this.title, required this.sectionIds});

  factory Module.fromJson(Map<String, dynamic> json) {
    List<String> sectionIds = [];
    if (json['sections'] != null) {
      sectionIds = List<String>.from(json['sections']);
    }

    return Module(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      sectionIds: sectionIds,
    );
  }
}

class Section {
  final String id;
  final String title;
  final int level;
  final String content;
  final List<Section> subsections;
  final String path;
  final String collection;

  Section({
    required this.id,
    required this.title,
    required this.level,
    required this.content,
    required this.subsections,
    required this.path,
    required this.collection,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    List<Section> subsections = [];
    if (json['subsections'] != null) {
      subsections = List<Section>.from(
        json['subsections'].map((subsection) => Section.fromJson(subsection)),
      );
    }

    return Section(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      level: json['level'] ?? 1,
      content: json['content'] ?? '',
      subsections: subsections,
      path: json['_path'] ?? '',
      collection: json['_collection'] ?? '',
    );
  }
}

class CourseService {
  static const String manualJsonPath = 'lib/assets/manual_plaintext.json';

  Future<Course?> getOxygenCourse() async {
    try {
      // Load the JSON data
      String jsonString = await rootBundle.loadString(manualJsonPath);
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Get the course data
      Course course = Course.fromJson(jsonData['course']);
      return course;
    } catch (e) {
      debugPrint('Error loading course data: $e');
      return null;
    }
  }

  Future<Map<String, Section>> getAllSections() async {
    try {
      // Load the JSON data
      String jsonString = await rootBundle.loadString(manualJsonPath);
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Get all sections
      Map<String, Section> sections = {};
      if (jsonData['sections'] != null) {
        for (var sectionJson in jsonData['sections']) {
          Section section = Section.fromJson(sectionJson);
          sections[section.id] = section;
        }
      }

      return sections;
    } catch (e) {
      debugPrint('Error loading sections: $e');
      return {};
    }
  }

  Future<List<Module>> getModulesForCourse(String courseId) async {
    Course? course = await getOxygenCourse();
    if (course != null && course.id == courseId) {
      return course.modules;
    }
    return [];
  }

  Future<List<Section>> getSectionsForModule(String moduleId) async {
    List<Section> result = [];
    Course? course = await getOxygenCourse();
    Map<String, Section> allSections = await getAllSections();

    if (course != null) {
      // Find the module
      Module? targetModule;
      for (var module in course.modules) {
        if (module.id == moduleId) {
          targetModule = module;
          break;
        }
      }

      // Get the sections for the module
      if (targetModule != null) {
        for (String sectionId in targetModule.sectionIds) {
          if (allSections.containsKey(sectionId)) {
            result.add(allSections[sectionId]!);
          }
        }
      }
    }

    return result;
  }
}
