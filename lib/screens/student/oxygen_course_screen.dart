import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../widgets/modern_layout.dart';
import '../../services/course_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model class for quiz questions
class QuizQuestion {
  final String id;
  final String text;
  final List<Map<String, dynamic>> images;
  final String type;
  final List<QuizOption> options;
  final String code;

  QuizQuestion({
    required this.id,
    required this.text,
    required this.images,
    required this.type,
    required this.options,
    required this.code,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    // Extract text content from HTML or plain text
    String questionText = json['content']['text'] ?? '';
    if (questionText.contains('![CDATA[')) {
      questionText = questionText
          .replaceAll('![CDATA[', '')
          .replaceAll(']]', '');
    }

    // Extract images from the content
    List<Map<String, dynamic>> questionImages = [];
    if (json['content']['images'] != null) {
      questionImages = List<Map<String, dynamic>>.from(
        json['content']['images'],
      );
    }

    // Parse options
    List<QuizOption> questionOptions = [];
    if (json['options'] != null) {
      questionOptions = List<QuizOption>.from(
        json['options'].map((option) => QuizOption.fromJson(option)),
      );
    }

    return QuizQuestion(
      id: json['_id'] ?? '',
      text: questionText,
      images: questionImages,
      type: json['type'] ?? 'meerkeuze',
      options: questionOptions,
      code: json['code'] ?? '',
    );
  }
}

class QuizOption {
  final String id;
  final String text;
  final bool isCorrect;

  QuizOption({required this.id, required this.text, required this.isCorrect});

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }
}

// At the top of the file, add the AssessmentItem class
class AssessmentItem {
  final String title;
  final String description;
  String competencyLevel; // Changed from final to mutable

  AssessmentItem({
    required this.title,
    required this.description,
    required this.competencyLevel,
  });
}

class OxygenCourseScreen extends StatefulWidget {
  const OxygenCourseScreen({super.key});

  @override
  State<OxygenCourseScreen> createState() => _OxygenCourseScreenState();
}

class _OxygenCourseScreenState extends State<OxygenCourseScreen>
    with SingleTickerProviderStateMixin {
  final CourseService _courseService = CourseService();
  late TabController _tabController;
  bool _isLoading = true;
  Course? _course;
  List<Module> _modules = [];
  Map<String, List<Section>> _moduleSections = {};
  Map<String, List<bool>> _completedSections = {}; // Track completed sections
  int _selectedModuleIndex = 0;

  // Quiz related properties
  List<QuizQuestion> _quizQuestions = [];
  bool _isLoadingQuiz = true;
  Map<String, List<String>> _userAnswers =
      {}; // Track user's answers by question ID
  Map<String, bool> _completedQuizzes = {}; // Track completed quizzes

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
    ); // Updated to 4 tabs (added Assessment)
    _loadCourseData();
    _loadQuizData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load quiz questions from the JSON file
  Future<void> _loadQuizData() async {
    setState(() {
      _isLoadingQuiz = true;
    });

    try {
      // Use hardcoded data since we're experiencing asset loading issues
      String jsonString = '''
      [
        {
          "_id": "question1",
          "content": {
            "text": "What is the name of the device used to provide oxygen to a conscious diver?",
            "images": []
          },
          "type": "meerkeuze",
          "options": [
            {"id": "option1", "text": "Demand Inhalator Valve and Mask", "is_correct": true},
            {"id": "option2", "text": "Pocket Mask Resuscitator", "is_correct": false},
            {"id": "option3", "text": "Bag Valve Mask (BVM) resuscitator", "is_correct": false}
          ],
          "code": "OX-Q1"
        },
        {
          "_id": "question2",
          "content": {
            "text": "What is the expected response time for provision of basic First-Aid including Oxygen administration?",
            "images": []
          },
          "type": "meerkeuze",
          "options": [
            {"id": "option1", "text": "4 minutes", "is_correct": true},
            {"id": "option2", "text": "20 minutes", "is_correct": false},
            {"id": "option3", "text": "60 minutes", "is_correct": false}
          ],
          "code": "OX-Q2"
        },
        {
          "_id": "question3",
          "content": {
            "text": "The duties and responsibilities of the designated oxygen provider are: (multiple correct answers)",
            "images": []
          },
          "type": "meermeerkeuze",
          "options": [
            {"id": "option1", "text": "Make sure the oxygen cylinder is re-filled and all used items replaced after any incident", "is_correct": true},
            {"id": "option2", "text": "To be competent in the correct use of oxygen at the surface and within the chamber", "is_correct": true},
            {"id": "option3", "text": "To complete daily checks to ensure all components are present and function tested", "is_correct": true},
            {"id": "option4", "text": "To ensure oxygen is on site, clearly labeled and accessible", "is_correct": true}
          ],
          "code": "OX-Q3"
        },
        {
          "_id": "question4",
          "content": {
            "text": "Which oxygen delivery device can be used on an Injured Person who is conscious, alert and orientated?",
            "images": []
          },
          "type": "meerkeuze",
          "options": [
            {"id": "option1", "text": "Demand Inhalator Valve and Mask", "is_correct": true},
            {"id": "option2", "text": "Pocket Mask Resuscitator", "is_correct": false},
            {"id": "option3", "text": "Bag Valve Mask (BVM) Resuscitator", "is_correct": false}
          ],
          "code": "OX-Q4"
        },
        {
          "_id": "question5",
          "content": {
            "text": "What flow rate should be used with a non-rebreather mask?",
            "images": []
          },
          "type": "meerkeuze",
          "options": [
            {"id": "option1", "text": "15 LPM", "is_correct": true},
            {"id": "option2", "text": "4 LPM", "is_correct": false},
            {"id": "option3", "text": "0 LPM", "is_correct": false}
          ],
          "code": "OX-Q5"
        }
      ]
      ''';

      // Parse questions
      final List<dynamic> jsonData = json.decode(jsonString);
      _quizQuestions =
          jsonData.map((data) => QuizQuestion.fromJson(data)).toList();

      // Load user answers and completed quizzes
      await _loadQuizProgress();
    } catch (e) {
      debugPrint('Error loading quiz data: $e');
      // Set up some sample questions so the UI isn't empty
      _setupSampleQuestions();
    } finally {
      setState(() {
        _isLoadingQuiz = false;
      });
    }
  }

  // Setup some sample questions if loading fails
  void _setupSampleQuestions() {
    _quizQuestions = [
      QuizQuestion(
        id: 'sample1',
        text: 'What flow rate should be used with a non-rebreather mask?',
        images: [],
        type: 'meerkeuze',
        options: [
          QuizOption(id: 'opt1', text: '15 LPM', isCorrect: true),
          QuizOption(id: 'opt2', text: '4 LPM', isCorrect: false),
          QuizOption(id: 'opt3', text: '0 LPM', isCorrect: false),
        ],
        code: 'SAMPLE-1',
      ),
      QuizQuestion(
        id: 'sample2',
        text:
            'Which of the following are part of the primary survey? (Select all that apply)',
        images: [],
        type: 'meermeerkeuze',
        options: [
          QuizOption(id: 'opt1', text: 'Hazards assessment', isCorrect: true),
          QuizOption(
            id: 'opt2',
            text: 'Assessing responsiveness',
            isCorrect: true,
          ),
          QuizOption(id: 'opt3', text: 'Airway check', isCorrect: true),
          QuizOption(
            id: 'opt4',
            text: 'Recording vital signs',
            isCorrect: false,
          ),
        ],
        code: 'SAMPLE-2',
      ),
    ];
  }

  // Load user's quiz progress from SharedPreferences
  Future<void> _loadQuizProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load user answers
      for (var question in _quizQuestions) {
        final answersKey = 'quiz_answers_${question.id}';
        final List<String>? answers = prefs.getStringList(answersKey);
        if (answers != null) {
          _userAnswers[question.id] = answers;
        }
      }

      // Load completed quizzes
      for (var question in _quizQuestions) {
        final completedKey = 'quiz_completed_${question.id}';
        final bool isCompleted = prefs.getBool(completedKey) ?? false;
        _completedQuizzes[question.id] = isCompleted;
      }
    } catch (e) {
      debugPrint('Error loading quiz progress: $e');
    }
  }

  // Save user's answer for a quiz question
  Future<void> _saveQuizAnswer(
    String questionId,
    String optionId,
    bool isMultipleChoice,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get current answers or initialize empty list
      List<String> currentAnswers = _userAnswers[questionId] ?? [];

      if (isMultipleChoice) {
        // For multiple choice: toggle the selection
        if (currentAnswers.contains(optionId)) {
          currentAnswers.remove(optionId);
        } else {
          currentAnswers.add(optionId);
        }
      } else {
        // For single choice: replace with the selected option
        currentAnswers = [optionId];
      }

      // Save to state and preferences
      setState(() {
        _userAnswers[questionId] = currentAnswers;
      });

      await prefs.setStringList('quiz_answers_${questionId}', currentAnswers);
    } catch (e) {
      debugPrint('Error saving quiz answer: $e');
    }
  }

  // Mark a quiz as completed
  Future<void> _markQuizCompleted(String questionId, bool isCompleted) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _completedQuizzes[questionId] = isCompleted;
      });

      await prefs.setBool('quiz_completed_${questionId}', isCompleted);
    } catch (e) {
      debugPrint('Error marking quiz as completed: $e');
    }
  }

  // Check if an answer is correct
  bool _isAnswerCorrect(QuizQuestion question) {
    // Get user's answers for this question
    final userAnswerIds = _userAnswers[question.id] ?? [];

    if (question.type == 'meerkeuze') {
      // Single choice: user must select the one correct option
      if (userAnswerIds.isEmpty) return false;

      // Find the selected option
      final selectedOption = question.options.firstWhere(
        (option) => option.id == userAnswerIds.first,
        orElse: () => QuizOption(id: '', text: '', isCorrect: false),
      );

      return selectedOption.isCorrect;
    } else if (question.type == 'meermeerkeuze') {
      // Multiple choice: user must select all correct options and no incorrect ones

      // Check if all user selected options are correct
      bool allSelectedOptionsCorrect = true;
      for (var answerId in userAnswerIds) {
        final option = question.options.firstWhere(
          (opt) => opt.id == answerId,
          orElse: () => QuizOption(id: '', text: '', isCorrect: false),
        );

        if (!option.isCorrect) {
          allSelectedOptionsCorrect = false;
          break;
        }
      }

      // Check if all correct options are selected
      final correctOptions =
          question.options.where((opt) => opt.isCorrect).toList();
      bool allCorrectOptionsSelected = correctOptions.every(
        (correctOpt) => userAnswerIds.contains(correctOpt.id),
      );

      return allSelectedOptionsCorrect && allCorrectOptionsSelected;
    }

    return false;
  }

  Future<void> _loadCourseData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load course data
      _course = await _courseService.getOxygenCourse();

      if (_course != null) {
        _modules = _course!.modules;

        // Load sections for each module
        for (var module in _modules) {
          List<Section> sections = await _courseService.getSectionsForModule(
            module.id,
          );
          _moduleSections[module.id] = sections;

          // Initialize completion tracking for each section
          await _loadCompletionData(module.id, sections.length);
        }
      }
    } catch (e) {
      debugPrint('Error loading course data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load completion data from SharedPreferences
  Future<void> _loadCompletionData(String moduleId, int sectionCount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<bool> completionStatus = [];

      for (int i = 0; i < sectionCount; i++) {
        final key = 'module_${moduleId}_section_$i';
        final isCompleted = prefs.getBool(key) ?? false;
        completionStatus.add(isCompleted);
      }

      setState(() {
        _completedSections[moduleId] = completionStatus;
      });
    } catch (e) {
      debugPrint('Error loading completion data: $e');
      // Initialize with false if error
      _completedSections[moduleId] = List.generate(sectionCount, (_) => false);
    }
  }

  // Save completion data for a section
  Future<void> _markSectionCompleted(String moduleId, int sectionIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'module_${moduleId}_section_$sectionIndex';
      await prefs.setBool(key, true);

      setState(() {
        if (_completedSections.containsKey(moduleId)) {
          if (sectionIndex < _completedSections[moduleId]!.length) {
            _completedSections[moduleId]![sectionIndex] = true;
          }
        }
      });
    } catch (e) {
      debugPrint('Error saving completion data: $e');
    }
  }

  // Check if a module is completely done
  bool _isModuleCompleted(String moduleId) {
    if (!_completedSections.containsKey(moduleId)) return false;

    final sectionsCompleted = _completedSections[moduleId]!;
    // All sections must be completed
    return sectionsCompleted.every((isCompleted) => isCompleted);
  }

  // Calculate module progress
  double _getModuleProgress(String moduleId) {
    if (!_completedSections.containsKey(moduleId)) return 0.0;

    final sectionsCompleted = _completedSections[moduleId]!;
    if (sectionsCompleted.isEmpty) return 0.0;

    int completedCount =
        sectionsCompleted.where((isCompleted) => isCompleted).length;
    return completedCount / sectionsCompleted.length;
  }

  // Get completed sections count
  int _getCompletedSectionsCount(String moduleId) {
    if (!_completedSections.containsKey(moduleId)) return 0;

    final sectionsCompleted = _completedSections[moduleId]!;
    return sectionsCompleted.where((isCompleted) => isCompleted).length;
  }

  @override
  Widget build(BuildContext context) {
    return ModernLayout(
      title: _course?.title ?? 'Oxygen Course',
      currentIndex: 1, // Assuming this is the courses tab
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildCourseContent(),
    );
  }

  Widget _buildCourseContent() {
    if (_course == null) {
      return const Center(child: Text('Could not load course content'));
    }

    return Column(
      children: [
        // Course Header with image and progress info
        _buildCourseHeader(),

        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            indicatorWeight: 2,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: const [
              Tab(text: 'Modules', height: 36),
              Tab(text: 'Discussion', height: 36),
              Tab(text: 'Resources', height: 36),
              Tab(text: 'Workplace Assessment', height: 36),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildModulesTab(),
              _buildPlaceholderTab('Discussion'),
              _buildPlaceholderTab('Resources'),
              _buildWorkplaceAssessmentTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseHeader() {
    // Calculate total course progress
    int totalSections = 0;
    int totalCompletedSections = 0;

    _modules.forEach((module) {
      final sectionCount = _moduleSections[module.id]?.length ?? 0;
      totalSections += sectionCount;
      totalCompletedSections += _getCompletedSectionsCount(module.id);
    });

    final courseProgress =
        totalSections > 0 ? totalCompletedSections / totalSections : 0.0;

    // Count completed modules
    int completedModules = 0;
    for (var module in _modules) {
      if (_isModuleCompleted(module.id)) {
        completedModules++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'lib/assets/images/course.jpg',
              height: 100,
              width: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: 140,
                  color: Colors.blue.shade100,
                  child: const Icon(
                    Icons.scuba_diving,
                    size: 48,
                    color: Colors.blue,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Course Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course info row
                Row(
                  children: [
                    // Duration
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '4 weeks',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Instructor
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.blue.shade200,
                            child: const Icon(
                              Icons.person,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Instructor Name',
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress section
                Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: courseProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(courseProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Modules completed
                Text(
                  '$completedModules of ${_modules.length} modules completed',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: _modules.length,
      itemBuilder: (context, index) {
        final module = _modules[index];
        final sections = _moduleSections[module.id] ?? [];

        // Calculate module progress based on actual completion
        bool isCompleted = _isModuleCompleted(module.id);
        double progress = _getModuleProgress(module.id);
        int completedSections = _getCompletedSectionsCount(module.id);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: Colors.grey.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              'Module ${index + 1}: ${module.title}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '$completedSections of ${sections.length} lessons completed',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : Colors.blue,
                  ),
                  minHeight: 4,
                ),
              ],
            ),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.play_circle_fill,
                  color: isCompleted ? Colors.green : Colors.blue,
                  size: 20,
                ),
              ),
            ),
            trailing: const Icon(Icons.keyboard_arrow_down, size: 20),
            children: [
              // List of sections in this module
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sections.length,
                itemBuilder: (context, sectionIndex) {
                  final section = sections[sectionIndex];

                  // Check if this section is completed
                  bool isSectionCompleted =
                      _completedSections[module.id] != null &&
                      sectionIndex < _completedSections[module.id]!.length &&
                      _completedSections[module.id]![sectionIndex];

                  return ListTile(
                    onTap: () {
                      _navigateToSectionContent(module, section, sectionIndex);
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color:
                            isSectionCompleted
                                ? Colors.green.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isSectionCompleted ? Icons.check : Icons.play_arrow,
                          color:
                              isSectionCompleted ? Colors.green : Colors.blue,
                          size: 16,
                        ),
                      ),
                    ),
                    title: Text(
                      section.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color:
                            isSectionCompleted
                                ? Colors.grey.shade600
                                : Colors.black87,
                        decoration:
                            isSectionCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSectionCompleted
                                ? Colors.green.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isSectionCompleted ? 'Completed' : 'Start',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color:
                              isSectionCompleted ? Colors.green : Colors.blue,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            title == 'Discussion' ? Icons.forum : Icons.menu_book,
            size: 48,
            color: Colors.blue.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '$title tab content coming soon',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _navigateToSectionContent(
    Module module,
    Section section,
    int sectionIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SectionContentScreen(
              moduleTitle: module.title,
              moduleId: module.id,
              section: section,
              sectionIndex: sectionIndex,
              sections: _moduleSections[module.id] ?? [],
              onSectionCompleted: (moduleId, sectionIndex) {
                _markSectionCompleted(moduleId, sectionIndex);
              },
            ),
      ),
    ).then((_) {
      // Refresh UI when returning from section content
      setState(() {});
    });
  }

  // Build the Workplace Assessment tab content
  Widget _buildWorkplaceAssessmentTab() {
    // The workplace assessment data from the file
    final List<AssessmentItem> assessmentItems = [
      // Safety First
      AssessmentItem(
        title: 'Safety First',
        description:
            'Ensures hands are clean and free from hand creams, oil and grease',
        competencyLevel: 'Not Yet Competent',
      ),
      AssessmentItem(
        title: 'Safety First',
        description: 'Ensure no open flames or sparks in work area',
        competencyLevel: 'Not Yet Competent',
      ),
      // Check the cylinder
      AssessmentItem(
        title: 'Check the cylinder',
        description:
            'Safety - Proper Position: Oxygen cylinder securely upright or lying down',
        competencyLevel: 'Not Yet Competent',
      ),
      AssessmentItem(
        title: 'Check the cylinder',
        description: 'Safety - no part of body over cylinder valve',
        competencyLevel: 'Not Yet Competent',
      ),
      AssessmentItem(
        title: 'Check the cylinder',
        description: 'Safety - correct cylinder colour coding and in date',
        competencyLevel: 'Not Yet Competent',
      ),
      AssessmentItem(
        title: 'Step 9: Re-stock',
        description: 'Follows company procedure for restocking DMAC 015',
        competencyLevel: 'Not Yet Competent',
      ),
      AssessmentItem(
        title: 'Attitude',
        description: 'Student displays proper attitude during assessment',
        competencyLevel: 'Negative',
      ),
    ];

    // Group items by title
    Map<String, List<AssessmentItem>> groupedItems = {};
    for (var item in assessmentItems) {
      if (!groupedItems.containsKey(item.title)) {
        groupedItems[item.title] = [];
      }
      groupedItems[item.title]!.add(item);
    }

    // Calculate assessment progress - items with competent status
    int completedItems =
        assessmentItems
            .where(
              (item) =>
                  item.competencyLevel == 'Competent' ||
                  item.competencyLevel == 'Positive',
            )
            .length;

    double progress =
        assessmentItems.isEmpty ? 0.0 : completedItems / assessmentItems.length;

    // Current score value (this would be calculated based on the assessment)
    double scoreValue = 7.5;
    TextEditingController remarksController = TextEditingController();

    return Column(
      children: [
        // Progress section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.assessment, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Assessment Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$completedItems of ${assessmentItems.length} completed',
                    style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0 ? Colors.green : Colors.blue,
                ),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),

        // Assessment items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Assessment items grouped by section
              ...groupedItems.entries.map((entry) {
                String title = entry.key;
                List<AssessmentItem> items = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Assessment items
                      ...items.map((item) {
                        if (item.title == 'Attitude') {
                          return _buildAttitudeRow(item);
                        } else {
                          return _buildAssessmentItemRow(item);
                        }
                      }),

                      const SizedBox(height: 8),
                    ],
                  ),
                );
              }).toList(),

              // Remarks section
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Remarks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Extra remarks regarding this assessment',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextField(
                              controller: remarksController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(12),
                                border: InputBorder.none,
                                hintText: 'Enter additional remarks here...',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Score section
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    '0',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 8,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 8,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                            overlayRadius: 16,
                                          ),
                                      activeTrackColor: Colors.blue,
                                      inactiveTrackColor: Colors.grey.shade200,
                                      thumbColor: Colors.blue,
                                    ),
                                    child: Slider(
                                      value: scoreValue,
                                      min: 0,
                                      max: 10,
                                      divisions: 20,
                                      onChanged: (value) {
                                        setState(() {
                                          scoreValue = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    '10',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current score: ${scoreValue.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom action buttons
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
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Save the assessment data
                  _saveAssessmentData(
                    assessmentItems,
                    remarksController.text,
                    scoreValue,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Save assessment data to shared preferences or backend
  Future<void> _saveAssessmentData(
    List<AssessmentItem> items,
    String remarks,
    double score,
  ) async {
    try {
      // Here you would save to SharedPreferences or to a backend
      // For this demo we'll just show a success message

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Assessment saved successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving assessment: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildAssessmentItemRow(AssessmentItem item) {
    bool hasSelection =
        item.competencyLevel != 'Not Yet Competent' &&
        item.competencyLevel != 'Negative';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color:
              hasSelection ? Colors.amber.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border:
              hasSelection
                  ? Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5)
                  : null,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(item.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            // Competency level selector
            _buildCompetencySelector(item),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetencySelector(AssessmentItem item) {
    bool isPositive =
        item.competencyLevel == 'Competent' ||
        item.competencyLevel == 'Positive';

    // This matches the screenshot with competency levels
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                _buildCompetencyOption(
                  'Not Yet Competent',
                  item.competencyLevel == 'Not Yet Competent',
                  () => _updateCompetencyLevel(item, 'Not Yet Competent'),
                ),
                _buildCompetencyOption(
                  'Skill gap',
                  item.competencyLevel == 'Skill gap',
                  () => _updateCompetencyLevel(item, 'Skill gap'),
                ),
                _buildCompetencyOption(
                  'Knowledge Gap',
                  item.competencyLevel == 'Knowledge Gap',
                  () => _updateCompetencyLevel(item, 'Knowledge Gap'),
                ),
                _buildCompetencyOption(
                  'Competent',
                  item.competencyLevel == 'Competent',
                  () => _updateCompetencyLevel(item, 'Competent'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            // Toggle between Competent and Not Yet Competent when clicking the checkmark
            setState(() {
              if (item.title == 'Attitude') {
                item.competencyLevel =
                    (item.competencyLevel == 'Positive')
                        ? 'Negative'
                        : 'Positive';
              } else {
                item.competencyLevel =
                    (item.competencyLevel == 'Competent')
                        ? 'Not Yet Competent'
                        : 'Competent';
              }
            });
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isPositive ? Colors.green : Colors.amber,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.check : Icons.pending,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompetencyOption(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            border: Border(right: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Method to update competency level
  void _updateCompetencyLevel(AssessmentItem item, String newLevel) {
    setState(() {
      // Only update if this is a different selection
      if (item.competencyLevel != newLevel) {
        item.competencyLevel = newLevel;
        // Show visual feedback for selection
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Assessment marked as: $newLevel'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  // For the attitude row, we need a special widget
  Widget _buildAttitudeRow(AssessmentItem item) {
    bool isPositive = item.competencyLevel == 'Positive';
    bool hasSelection = item.competencyLevel != 'Negative';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color:
              hasSelection ? Colors.amber.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border:
              hasSelection
                  ? Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5)
                  : null,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(item.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            // Attitude selector
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        _buildCompetencyOption(
                          'Negative',
                          item.competencyLevel == 'Negative',
                          () => _updateCompetencyLevel(item, 'Negative'),
                        ),
                        _buildCompetencyOption(
                          'Lacks attention',
                          item.competencyLevel == 'Lacks attention',
                          () => _updateCompetencyLevel(item, 'Lacks attention'),
                        ),
                        _buildCompetencyOption(
                          'Positive',
                          item.competencyLevel == 'Positive',
                          () => _updateCompetencyLevel(item, 'Positive'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Toggle between Positive and Negative when clicking the checkmark
                    setState(() {
                      item.competencyLevel =
                          isPositive ? 'Negative' : 'Positive';
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isPositive ? Colors.green : Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPositive ? Icons.check : Icons.pending,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to display error image when images fail to load
  Widget _buildErrorImage() {
    return Container(
      height: 100,
      width: 150,
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
      ),
    );
  }
}

// New screen for section content
class SectionContentScreen extends StatefulWidget {
  final String moduleTitle;
  final String moduleId;
  final Section section;
  final int sectionIndex;
  final List<Section> sections;
  final Function(String moduleId, int sectionIndex) onSectionCompleted;

  const SectionContentScreen({
    super.key,
    required this.moduleTitle,
    required this.moduleId,
    required this.section,
    required this.sectionIndex,
    required this.sections,
    required this.onSectionCompleted,
  });

  @override
  State<SectionContentScreen> createState() => _SectionContentScreenState();
}

class _SectionContentScreenState extends State<SectionContentScreen> {
  bool _hasViewedContent = false;

  @override
  void initState() {
    super.initState();
    // Mark as viewed after a delay (simulating content viewing)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _hasViewedContent = true;
        });
      }
    });
  }

  @override
  void dispose() {
    // Mark this section as completed when navigating away
    if (_hasViewedContent) {
      widget.onSectionCompleted(widget.moduleId, widget.sectionIndex);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Blue header
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.moduleTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Module Progress',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (widget.sectionIndex + 1) / widget.sections.length,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section content card with blue background
                    Card(
                      elevation: 2,
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Lesson Content',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Section title
                            Row(
                              children: [
                                Text(
                                  "Slide ${widget.sectionIndex + 1}:",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.section.title.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Time estimate
                            const SizedBox(height: 12),
                            const Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Estimated time: 15 minutes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Main content
                    Text(
                      widget.section.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section content
                    _buildFormattedContent(widget.section.content),

                    // Subsections
                    if (widget.section.subsections.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      for (var subsection in widget.section.subsections) ...[
                        Text(
                          subsection.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFormattedContent(subsection.content),
                        const SizedBox(height: 24),
                      ],
                    ],

                    // Key points section (if appropriate)
                    Card(
                      elevation: 1,
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Key Points',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildKeyPoint('Emergency procedures for divers'),
                            _buildKeyPoint('First aid for underwater injuries'),
                            _buildKeyPoint(
                              'Safety protocols for bleeding control',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              widget.sectionIndex > 0
                                  ? () => _navigateToSection(
                                    widget.sectionIndex - 1,
                                  )
                                  : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black87,
                            disabledBackgroundColor: Colors.grey.shade100,
                            disabledForegroundColor: Colors.grey.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed:
                              widget.sectionIndex < widget.sections.length - 1
                                  ? () => _navigateToSection(
                                    widget.sectionIndex + 1,
                                  )
                                  : null,
                          label: const Text('Next'),
                          icon: const Icon(Icons.arrow_forward),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade100,
                            disabledForegroundColor: Colors.grey.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.check, size: 12, color: Colors.blue),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedContent(String content) {
    // Split content into paragraphs
    List<String> paragraphs = content.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          paragraphs.map((paragraph) {
            // Skip empty paragraphs
            if (paragraph.trim().isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                paragraph,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            );
          }).toList(),
    );
  }

  void _navigateToSection(int index) {
    if (index >= 0 && index < widget.sections.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => SectionContentScreen(
                moduleTitle: widget.moduleTitle,
                moduleId: widget.moduleId,
                section: widget.sections[index],
                sectionIndex: index,
                sections: widget.sections,
                onSectionCompleted: widget.onSectionCompleted,
              ),
        ),
      );
    }
  }
}
