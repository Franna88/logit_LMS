import 'package:flutter/material.dart';
import '../../widgets/modern_layout.dart';
import '../../services/course_service.dart';

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
  int _selectedModuleIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCourseData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseHeader() {
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
                        value: 0.3, // Example value
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
                      '30%',
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
                  '2 of ${_modules.length} modules completed',
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

        // Calculate module progress for demo
        bool isCompleted = index < 2; // First two modules completed for demo
        double progress = isCompleted ? 1.0 : (index == 2 ? 0.0 : 0.0);
        int completedSections = isCompleted ? sections.length : 0;

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
                  bool isSectionCompleted =
                      isCompleted || (index == 2 && sectionIndex < 2);

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
              section: section,
              sectionIndex: sectionIndex,
              sections: _moduleSections[module.id] ?? [],
            ),
      ),
    );
  }
}

// New screen for section content
class SectionContentScreen extends StatefulWidget {
  final String moduleTitle;
  final Section section;
  final int sectionIndex;
  final List<Section> sections;

  const SectionContentScreen({
    super.key,
    required this.moduleTitle,
    required this.section,
    required this.sectionIndex,
    required this.sections,
  });

  @override
  State<SectionContentScreen> createState() => _SectionContentScreenState();
}

class _SectionContentScreenState extends State<SectionContentScreen> {
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
                section: widget.sections[index],
                sectionIndex: index,
                sections: widget.sections,
              ),
        ),
      );
    }
  }
}
