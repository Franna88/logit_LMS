import 'package:flutter/material.dart';
import '../../widgets/admin_layout.dart';
import '../../screens/modules/quiz_screen.dart';
import 'create_quiz_screen.dart';

class CreateModuleScreen extends StatefulWidget {
  const CreateModuleScreen({super.key});

  @override
  State<CreateModuleScreen> createState() => _CreateModuleScreenState();
}

class _CreateModuleScreenState extends State<CreateModuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final List<Map<String, dynamic>> _contentItems = [];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addContentItem(Map<String, dynamic> item) {
    setState(() {
      _contentItems.add(item);
    });
  }

  void _removeContentItem(int index) {
    setState(() {
      _contentItems.removeAt(index);
    });
  }

  void _moveContentItem(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _contentItems.removeAt(oldIndex);
      _contentItems.insert(newIndex, item);
    });
  }

  Future<void> _showAddContentDialog() async {
    String contentType = 'introduction';
    final contentTitleController = TextEditingController();
    final contentDurationController = TextEditingController();
    int? timeLimit;
    bool isPractice = true;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Content'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: contentTitleController,
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
                                        type[0].toUpperCase() +
                                            type.substring(1),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              contentType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: contentDurationController,
                          decoration: const InputDecoration(
                            labelText: 'Duration',
                            hintText: 'e.g., 15 min',
                          ),
                        ),

                        // Special fields based on content type
                        if (contentType == 'quiz' ||
                            contentType == 'assessment') ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Time Limit (minutes)',
                                    hintText: 'e.g., 30',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    timeLimit = int.tryParse(value);
                                  },
                                ),
                              ),
                              if (contentType == 'quiz') ...[
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SwitchListTile(
                                    title: const Text('Practice Mode'),
                                    value: isPractice,
                                    onChanged: (value) {
                                      setState(() {
                                        isPractice = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (contentTitleController.text.isNotEmpty &&
                            contentDurationController.text.isNotEmpty) {
                          if (contentType == 'quiz' ||
                              contentType == 'assessment') {
                            // Navigate to quiz creation screen
                            final questions =
                                await Navigator.push<List<QuizQuestion>>(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CreateQuizScreen(
                                          moduleTitle: _titleController.text,
                                          isPractice: isPractice,
                                          timeLimit: timeLimit,
                                        ),
                                  ),
                                );

                            if (questions != null) {
                              _addContentItem({
                                'title': contentTitleController.text,
                                'type': contentType,
                                'duration': contentDurationController.text,
                                'isCompleted': false,
                                'questions': questions,
                                'isPractice': isPractice,
                                'timeLimit': timeLimit,
                              });
                            }
                          } else {
                            _addContentItem({
                              'title': contentTitleController.text,
                              'type': contentType,
                              'duration': contentDurationController.text,
                              'isCompleted': false,
                            });
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _saveModule() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement module saving logic
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Create New Module',
      currentIndex: -1,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Module Title',
                  hintText: 'e.g., Module 1: Introduction to Course',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a module title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Content items section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Content Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddContentDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Content'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Add videos, lessons, quizzes, and other content to this module.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Content items list
              Expanded(
                child:
                    _contentItems.isEmpty
                        ? _buildEmptyState()
                        : _buildContentList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_add, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No content items yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add videos, lessons, quizzes, or other content',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddContentDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add First Content Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ReorderableListView.builder(
        onReorder: _moveContentItem,
        itemCount: _contentItems.length,
        itemBuilder: (context, index) {
          final item = _contentItems[index];
          final IconData typeIcon = _getContentTypeIcon(item['type'] as String);
          final Color typeColor = _getContentTypeColor(item['type'] as String);

          return ListTile(
            key: ValueKey('content-$index'),
            leading: CircleAvatar(
              backgroundColor: typeColor.withOpacity(0.2),
              child: Icon(typeIcon, color: typeColor, size: 20),
            ),
            title: Text(item['title'] as String),
            subtitle: Text(
              '${item['type'][0].toUpperCase()}${item['type'].substring(1)} • ${item['duration']}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item['type'] == 'quiz' || item['type'] == 'assessment')
                  Text(
                    '${(item['questions'] as List<QuizQuestion>).length} questions',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeContentItem(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getContentTypeIcon(String type) {
    switch (type) {
      case 'introduction':
        return Icons.info_outline;
      case 'video':
        return Icons.play_circle_outline;
      case 'lesson':
        return Icons.menu_book;
      case 'exercise':
        return Icons.fitness_center;
      case 'quiz':
        return Icons.quiz;
      case 'assessment':
        return Icons.assignment;
      default:
        return Icons.article_outlined;
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
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
