import 'package:flutter/material.dart';
import '../../widgets/admin_layout.dart';
import '../../screens/modules/quiz_screen.dart';

class CreateQuizScreen extends StatefulWidget {
  final String moduleTitle;
  final bool isPractice;
  final int? timeLimit;

  const CreateQuizScreen({
    super.key,
    required this.moduleTitle,
    this.isPractice = true,
    this.timeLimit,
  });

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final List<QuizQuestion> _questions = [];
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctAnswerIndex = 0;
  final _explanationController = TextEditingController();
  String? _imageUrl;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    _explanationController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _questions.add(
          QuizQuestion(
            questionText: _questionController.text,
            answerOptions: _answerControllers.map((c) => c.text).toList(),
            correctAnswerIndex: _correctAnswerIndex,
            explanation:
                _explanationController.text.isEmpty
                    ? null
                    : _explanationController.text,
            imageUrl: _imageUrl,
          ),
        );
        // Reset form
        _questionController.clear();
        for (var controller in _answerControllers) {
          controller.clear();
        }
        _explanationController.clear();
        _imageUrl = null;
        _correctAnswerIndex = 0;
      });
    }
  }

  void _editQuestion(int index) {
    final question = _questions[index];
    _questionController.text = question.questionText;
    for (int i = 0; i < _answerControllers.length; i++) {
      _answerControllers[i].text = question.answerOptions[i];
    }
    _correctAnswerIndex = question.correctAnswerIndex;
    _explanationController.text = question.explanation ?? '';
    _imageUrl = question.imageUrl;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Question'),
            content: SingleChildScrollView(child: _buildQuestionForm()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _questions[index] = QuizQuestion(
                        questionText: _questionController.text,
                        answerOptions:
                            _answerControllers.map((c) => c.text).toList(),
                        correctAnswerIndex: _correctAnswerIndex,
                        explanation:
                            _explanationController.text.isEmpty
                                ? null
                                : _explanationController.text,
                        imageUrl: _imageUrl,
                      );
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

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Widget _buildQuestionForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _questionController,
            decoration: const InputDecoration(
              labelText: 'Question',
              hintText: 'Enter your question here',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a question';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Answer Options',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            _answerControllers.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Radio<int>(
                    value: index,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) {
                      setState(() {
                        _correctAnswerIndex = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _answerControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Option ${index + 1}',
                        hintText: 'Enter answer option',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an answer option';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _explanationController,
            decoration: const InputDecoration(
              labelText: 'Explanation (Optional)',
              hintText: 'Explain why this is the correct answer',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _imageUrl,
            decoration: const InputDecoration(
              labelText: 'Image URL (Optional)',
              hintText: 'Enter URL for question image',
            ),
            onChanged: (value) {
              _imageUrl = value.isEmpty ? null : value;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Create Quiz',
      currentIndex: -1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quiz Questions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Add Question'),
                            content: SingleChildScrollView(
                              child: _buildQuestionForm(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _addQuestion();
                                  Navigator.pop(context);
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _questions.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.quiz, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No questions yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add questions to create your quiz',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        final question = _questions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Question ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editQuestion(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _removeQuestion(index),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(question.questionText),
                                const SizedBox(height: 16),
                                ...List.generate(
                                  question.answerOptions.length,
                                  (i) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          i == question.correctAnswerIndex
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          color:
                                              i == question.correctAnswerIndex
                                                  ? Colors.green
                                                  : Colors.grey,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(question.answerOptions[i]),
                                      ],
                                    ),
                                  ),
                                ),
                                if (question.explanation != null) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Explanation:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(question.explanation!),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed:
                      _questions.isEmpty
                          ? null
                          : () {
                            Navigator.pop(context, _questions);
                          },
                  child: const Text('Save Quiz'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
