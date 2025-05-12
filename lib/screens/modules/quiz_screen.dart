import 'package:flutter/material.dart';
import '../../widgets/modern_layout.dart';
import '../../utils/timer.dart'; // Import the real timer

class QuizScreen extends StatefulWidget {
  final String moduleTitle;
  final String quizTitle;
  final List<QuizQuestion> questions;
  final bool isPractice; // If true, shows answers after each question
  final int? timeLimit; // In minutes, null for no time limit
  final Function(int, int) onComplete; // Parameters: score, total questions
  final VoidCallback onExit;

  const QuizScreen({
    super.key,
    required this.moduleTitle,
    required this.quizTitle,
    required this.questions,
    required this.isPractice,
    this.timeLimit,
    required this.onComplete,
    required this.onExit,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  List<int?> _userAnswers = [];
  List<bool> _answeredCorrectly = [];
  bool _quizCompleted = false;
  int _score = 0;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _showExplanation = false;

  @override
  void initState() {
    super.initState();
    _userAnswers = List.filled(widget.questions.length, null);
    _answeredCorrectly = List.filled(widget.questions.length, false);

    // Initialize timer if needed
    if (widget.timeLimit != null) {
      _remainingSeconds = widget.timeLimit! * 60;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _submitQuiz();
        }
      });
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(int questionIndex, int answerIndex) {
    if (_quizCompleted) return;

    setState(() {
      _userAnswers[questionIndex] = answerIndex;

      // Just record the answer, don't show feedback yet
      if (widget.isPractice) {
        _answeredCorrectly[questionIndex] =
            widget.questions[questionIndex].correctAnswerIndex == answerIndex;
        // No longer showing immediate feedback
        _showExplanation = false;
      }
    });
  }

  void _moveToNextQuestion() {
    setState(() {
      _showExplanation = false;
      if (_currentQuestionIndex < widget.questions.length - 1) {
        _currentQuestionIndex++;
      } else if (!_quizCompleted) {
        _submitQuiz();
      }
    });
  }

  void _moveToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _showExplanation =
            widget.isPractice && _userAnswers[_currentQuestionIndex] != null;
      });
    }
  }

  void _submitQuiz() {
    if (_quizCompleted) return;

    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (_userAnswers[i] != null &&
          _userAnswers[i] == widget.questions[i].correctAnswerIndex) {
        correctAnswers++;
        _answeredCorrectly[i] = true;
      } else {
        _answeredCorrectly[i] = false;
      }
    }

    _score = correctAnswers;
    _quizCompleted = true;
    _timer?.cancel();

    // Call the completion callback with the score
    widget.onComplete(_score, widget.questions.length);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ModernLayout(
      title: widget.moduleTitle,
      showBackButton: true,
      currentIndex: -1,
      child: _quizCompleted ? _buildResultScreen() : _buildQuizScreen(),
    );
  }

  Widget _buildQuizScreen() {
    final currentQuestion = widget.questions[_currentQuestionIndex];
    final bool hasAnswered = _userAnswers[_currentQuestionIndex] != null;

    return Column(
      children: [
        // Timer and progress bar
        _buildQuizHeader(),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question
                Text(
                  currentQuestion.questionText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (currentQuestion.imageUrl != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      currentQuestion.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Answer choices
                ...List.generate(
                  currentQuestion.answerOptions.length,
                  (index) => _buildAnswerOption(
                    index,
                    currentQuestion.answerOptions[index],
                    _userAnswers[_currentQuestionIndex] == index,
                    null, // No correctness indication during the quiz
                  ),
                ),

                // Remove the feedback container during the quiz
                const SizedBox(height: 80), // Space for navigation buttons
              ],
            ),
          ),
        ),

        // Navigation buttons
        Align(alignment: Alignment.bottomCenter, child: _buildNavigationBar()),
      ],
    );
  }

  Widget _buildQuizHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        children: [
          // Timer and question counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${widget.questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (widget.timeLimit != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _remainingSeconds < 60
                            ? Colors.red.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color:
                            _remainingSeconds < 60 ? Colors.red : Colors.blue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formattedTime,
                        style: TextStyle(
                          color:
                              _remainingSeconds < 60 ? Colors.red : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.questions.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            borderRadius: BorderRadius.circular(6),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(
    int index,
    String answerText,
    bool isSelected,
    bool? isCorrect,
  ) {
    // During the quiz, only show selection state, not correctness
    Color backgroundColor =
        isSelected ? Colors.blue.withOpacity(0.1) : Colors.white;
    Color borderColor = isSelected ? Colors.blue : Colors.grey.withOpacity(0.5);
    Color textColor = isSelected ? Colors.blue : Colors.black87;

    // Only in the completed state (results screen) show correct/incorrect
    if (_quizCompleted) {
      if (index == widget.questions[_currentQuestionIndex].correctAnswerIndex) {
        // Correct answer
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green;
      } else if (isSelected) {
        // Selected wrong answer
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap:
            _quizCompleted
                ? null
                : () => _selectAnswer(_currentQuestionIndex, index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected ? Colors.blue : Colors.grey.withOpacity(0.2),
                  border: Border.all(
                    color:
                        isSelected ? Colors.blue : Colors.grey.withOpacity(0.5),
                  ),
                ),
                child: Center(
                  child:
                      isSelected
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                          : Text(
                            String.fromCharCode(65 + index), // A, B, C, D, etc.
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  answerText,
                  style: TextStyle(
                    color: textColor,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    final bool hasAnswered = _userAnswers[_currentQuestionIndex] != null;
    final bool isLastQuestion =
        _currentQuestionIndex == widget.questions.length - 1;
    final bool readyForNext = widget.isPractice ? hasAnswered : true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          ElevatedButton.icon(
            onPressed:
                _currentQuestionIndex > 0 ? _moveToPreviousQuestion : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue,
              backgroundColor: Colors.white,
              elevation: 0,
              disabledForegroundColor: Colors.grey.withOpacity(0.38),
              disabledBackgroundColor: Colors.grey.withOpacity(0.12),
            ),
          ),

          // Next or Submit Button
          ElevatedButton.icon(
            onPressed:
                !readyForNext
                    ? null
                    : isLastQuestion
                    ? _submitQuiz
                    : _moveToNextQuestion,
            icon: Icon(
              isLastQuestion ? Icons.check_circle : Icons.arrow_forward,
            ),
            label: Text(isLastQuestion ? 'Submit Quiz' : 'Next'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: isLastQuestion ? Colors.green : Colors.blue,
              disabledForegroundColor: Colors.grey.withOpacity(0.38),
              disabledBackgroundColor: Colors.grey.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (_score / widget.questions.length) * 100;
    final bool isPassing = percentage >= 70;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // Score display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:
                  isPassing
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isPassing ? Colors.green : Colors.red),
            ),
            child: Column(
              children: [
                Icon(
                  isPassing ? Icons.check_circle : Icons.cancel,
                  size: 64,
                  color: isPassing ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  isPassing ? 'Congratulations!' : 'Keep Practicing',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isPassing ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Score: $_score/${widget.questions.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${percentage.round()}%',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isPassing ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isPassing
                      ? 'Great job! You\'ve passed this quiz.'
                      : 'You need 70% to pass. Try again!',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Question review
          if (widget.isPractice) ...[
            const Text(
              'Question Review',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ...List.generate(
              widget.questions.length,
              (index) => _buildQuestionReviewItem(index),
            ),
          ],

          const SizedBox(height: 32),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onExit,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Course'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (!isPassing && widget.isPractice)
                ElevatedButton.icon(
                  onPressed: () {
                    // Reset the quiz to try again
                    setState(() {
                      _currentQuestionIndex = 0;
                      _userAnswers = List.filled(widget.questions.length, null);
                      _answeredCorrectly = List.filled(
                        widget.questions.length,
                        false,
                      );
                      _quizCompleted = false;
                      _showExplanation = false;

                      if (widget.timeLimit != null) {
                        _remainingSeconds = widget.timeLimit! * 60;
                        _startTimer();
                      }
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionReviewItem(int index) {
    final question = widget.questions[index];
    final userAnswer = _userAnswers[index];
    final bool isCorrect = userAnswer == question.correctAnswerIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              userAnswer == null
                  ? Colors.grey
                  : isCorrect
                  ? Colors.green
                  : Colors.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Question ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const Spacer(),
              if (userAnswer != null)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 20,
                ),
              if (userAnswer != null)
                Text(
                  isCorrect ? ' Correct' : ' Incorrect',
                  style: TextStyle(
                    color: isCorrect ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Question text
          Text(
            question.questionText,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 8),

          // User's answer
          if (userAnswer != null) ...[
            const Text(
              'Your answer:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              question.answerOptions[userAnswer],
              style: TextStyle(color: isCorrect ? Colors.green : Colors.red),
            ),
          ],

          // Correct answer (if user was wrong)
          if (userAnswer != null && !isCorrect) ...[
            const SizedBox(height: 8),
            const Text(
              'Correct answer:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              question.answerOptions[question.correctAnswerIndex],
              style: const TextStyle(color: Colors.green),
            ),
          ],

          // Explanation
          if (question.explanation != null) ...[
            const SizedBox(height: 8),
            const Text(
              'Explanation:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(question.explanation!),
          ],
        ],
      ),
    );
  }
}

class QuizQuestion {
  final String questionText;
  final List<String> answerOptions;
  final int correctAnswerIndex;
  final String? explanation;
  final String? imageUrl;

  QuizQuestion({
    required this.questionText,
    required this.answerOptions,
    required this.correctAnswerIndex,
    this.explanation,
    this.imageUrl,
  });
}
