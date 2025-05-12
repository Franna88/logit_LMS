import 'package:flutter/material.dart';
import 'create_module_screen.dart';

class EditCourseScreen extends StatefulWidget {
  final String courseId;

  const EditCourseScreen({super.key, required this.courseId});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Technology';
  String _selectedStatus = 'Published';

  Map<String, dynamic>? _course;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCourseData();
  }

  void _loadCourseData() {
    // Simulate loading course data
    // In a real app, this would fetch from a database
    setState(() {
      _course = {
        'id': widget.courseId,
        'title': 'Diving Safety and Awareness',
        'description':
            'A comprehensive course on diving safety and protocols to ensure safe underwater experiences.',
        'category': 'Sports',
        'status': 'Published',
        'imageUrl': 'lib/assets/images/course.jpg',
        'modules': [
          {
            'id': '1',
            'title': 'Module 1: Introduction to Diving Safety',
            'completedLessons': 4,
            'totalLessons': 4,
            'progress': 1.0,
            'isCompleted': true,
            'contentItems': [
              {
                'title': 'Introduction to the Course',
                'type': 'introduction',
                'duration': '5 min',
                'isCompleted': true,
              },
              {
                'title': 'Diving Equipment Overview',
                'type': 'video',
                'duration': '15 min',
                'isCompleted': true,
              },
              {
                'title': 'Pre-Dive Safety Checks',
                'type': 'lesson',
                'duration': '25 min',
                'isCompleted': true,
              },
              {
                'title': 'Module Quiz',
                'type': 'quiz',
                'duration': '10 min',
                'isCompleted': true,
              },
            ],
          },
          {
            'id': '2',
            'title': 'Module 2: Dive Planning and Risk Assessment',
            'completedLessons': 5,
            'totalLessons': 5,
            'progress': 1.0,
            'isCompleted': true,
            'contentItems': [
              {
                'title': 'Dive Planning Basics',
                'type': 'video',
                'duration': '20 min',
                'isCompleted': true,
              },
              {
                'title': 'Weather and Water Conditions',
                'type': 'video',
                'duration': '25 min',
                'isCompleted': true,
              },
              {
                'title': 'Risk Assessment Techniques',
                'type': 'lesson',
                'duration': '15 min',
                'isCompleted': true,
              },
              {
                'title': 'Creating a Dive Plan',
                'type': 'exercise',
                'duration': '45 min',
                'isCompleted': true,
              },
              {
                'title': 'Module Quiz',
                'type': 'quiz',
                'duration': '15 min',
                'isCompleted': true,
              },
            ],
          },
        ],
      };

      _titleController.text = _course!['title'];
      _descriptionController.text = _course!['description'];
      _selectedCategory = _course!['category'];
      _selectedStatus = _course!['status'];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_course == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Course'),
        actions: [
          TextButton.icon(
            onPressed: _saveCourse,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Course Details'),
                Tab(text: 'Modules'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildModulesTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course image section
          Center(
            child: Stack(
              children: [
                Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(_course!['imageUrl']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: () {
                      // Show image picker
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Course title
          const Text(
            'Course Title',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Enter course title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Course description
          const Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Enter course description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),

          // Category
          const Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items:
                ['Technology', 'Business', 'Sports', 'Arts', 'Science']
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Status
          const Text(
            'Status',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items:
                ['Published', 'Draft']
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModulesTab() {
    final modules = _course!['modules'] as List<dynamic>;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Course Modules',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin_create_module');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Module'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Modules list with reordering
          Expanded(
            child: ReorderableListView.builder(
              itemCount: modules.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = modules.removeAt(oldIndex);
                  modules.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final module = modules[index] as Map<String, dynamic>;
                return Card(
                  key: ValueKey(module['id']),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      module['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${module['totalLessons']} items',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    children: [
                      _buildModuleContentList(module),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              // Navigate to edit module screen
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // Add content to this module
                              _showAddContentDialog(module);
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Content'),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // Show delete confirmation
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Delete Module?'),
                                      content: Text(
                                        'Are you sure you want to delete "${module['title']}"? This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              modules.removeAt(index);
                                            });
                                            Navigator.pop(context);
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text('Delete'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleContentList(Map<String, dynamic> module) {
    final contentItems = module['contentItems'] as List<dynamic>;

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contentItems.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = contentItems.removeAt(oldIndex);
          contentItems.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final item = contentItems[index] as Map<String, dynamic>;
        final IconData typeIcon = _getContentTypeIcon(item['type'] as String);
        final Color typeColor = _getContentTypeColor(item['type'] as String);

        return ListTile(
          key: ValueKey('${module['id']}-content-$index'),
          leading: CircleAvatar(
            backgroundColor: typeColor.withOpacity(0.2),
            child: Icon(typeIcon, color: typeColor, size: 16),
          ),
          title: Text(item['title'] as String),
          subtitle: Text(
            '${item['type'].toString().toUpperCase()} • ${item['duration']}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 16),
                onPressed: () {
                  // Edit content item
                  _showEditContentDialog(module, index);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                onPressed: () {
                  setState(() {
                    contentItems.removeAt(index);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddContentDialog(Map<String, dynamic> module) {
    final contentTitle = TextEditingController();
    final contentDuration = TextEditingController();
    String contentType = 'lesson';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Content'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: contentTitle,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter content title',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: contentType,
                    decoration: const InputDecoration(
                      labelText: 'Content Type',
                    ),
                    items:
                        [
                              'introduction',
                              'video',
                              'lesson',
                              'exercise',
                              'quiz',
                              'assessment',
                            ]
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type[0].toUpperCase() + type.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      contentType = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentDuration,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      hintText: 'e.g., 15 min',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (contentTitle.text.isNotEmpty &&
                      contentDuration.text.isNotEmpty) {
                    setState(() {
                      final contentItems =
                          module['contentItems'] as List<dynamic>;
                      contentItems.add({
                        'title': contentTitle.text,
                        'type': contentType,
                        'duration': contentDuration.text,
                        'isCompleted': false,
                      });
                      // Update module total lessons count
                      module['totalLessons'] = contentItems.length;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _showEditContentDialog(Map<String, dynamic> module, int contentIndex) {
    final contentItems = module['contentItems'] as List<dynamic>;
    final item = contentItems[contentIndex] as Map<String, dynamic>;

    final contentTitle = TextEditingController(text: item['title'] as String);
    final contentDuration = TextEditingController(
      text: item['duration'] as String,
    );
    String contentType = item['type'] as String;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Content'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: contentTitle,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: contentType,
                    decoration: const InputDecoration(
                      labelText: 'Content Type',
                    ),
                    items:
                        [
                              'introduction',
                              'video',
                              'lesson',
                              'exercise',
                              'quiz',
                              'assessment',
                            ]
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type[0].toUpperCase() + type.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      contentType = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentDuration,
                    decoration: const InputDecoration(labelText: 'Duration'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (contentTitle.text.isNotEmpty &&
                      contentDuration.text.isNotEmpty) {
                    setState(() {
                      item['title'] = contentTitle.text;
                      item['type'] = contentType;
                      item['duration'] = contentDuration.text;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Course Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Settings cards
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visibility',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Public Course'),
                    subtitle: const Text(
                      'Make this course visible to all users',
                    ),
                    value: true,
                    onChanged: (value) {},
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Allow Enrollment'),
                    subtitle: const Text('Let students enroll in this course'),
                    value: true,
                    onChanged: (value) {},
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Certificate',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Enable Certificates'),
                    subtitle: const Text(
                      'Award certificates upon course completion',
                    ),
                    value: true,
                    onChanged: (value) {},
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  // Certificate template selection
                  const Text('Certificate Template'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: 'Standard',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items:
                        ['Standard', 'Professional', 'Advanced']
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Danger Zone',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Delete Course?'),
                              content: const Text(
                                'Are you sure you want to permanently delete this course? This action cannot be undone and will remove all associated modules, content, and student enrollment data.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                      );
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Delete Course'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveCourse() {
    // Save course logic here
    // In a real app, this would update the database
    setState(() {
      _course!['title'] = _titleController.text;
      _course!['description'] = _descriptionController.text;
      _course!['category'] = _selectedCategory;
      _course!['status'] = _selectedStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Course saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  IconData _getContentTypeIcon(String type) {
    switch (type) {
      case 'introduction':
        return Icons.book;
      case 'video':
        return Icons.play_circle_filled;
      case 'lesson':
        return Icons.article;
      case 'exercise':
        return Icons.assignment;
      case 'quiz':
        return Icons.quiz;
      case 'assessment':
        return Icons.school;
      default:
        return Icons.article;
    }
  }

  Color _getContentTypeColor(String type) {
    switch (type) {
      case 'introduction':
        return Colors.blue;
      case 'video':
        return Colors.red;
      case 'lesson':
        return Colors.green;
      case 'exercise':
        return Colors.orange;
      case 'quiz':
        return Colors.purple;
      case 'assessment':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
