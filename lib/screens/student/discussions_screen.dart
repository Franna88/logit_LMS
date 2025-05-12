import 'package:flutter/material.dart';
import '../../widgets/modern_layout.dart';

class DiscussionsScreen extends StatefulWidget {
  const DiscussionsScreen({super.key});

  @override
  State<DiscussionsScreen> createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernLayout(
      title: 'Discussions',
      currentIndex: 5,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            // Create new discussion or message based on current tab
            final currentTab = _tabController.index;
            if (currentTab == 0) {
              _showNewForumPostDialog();
            } else if (currentTab == 1) {
              _showNewQuestionDialog();
            } else {
              _showNewMessageDialog();
            }
          },
        ),
      ],
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Forums'),
              Tab(text: 'Q&A'),
              Tab(text: 'Messages'),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildForumsTab(),
                _buildQuestionsTab(),
                _buildMessagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForumsTab() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCategorySection(),
              const SizedBox(height: 24),
              _buildRecentDiscussionsSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search discussions...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryCard('General', Icons.forum, Colors.blue, 25),
              _buildCategoryCard(
                'Safety',
                Icons.health_and_safety,
                Colors.green,
                42,
              ),
              _buildCategoryCard(
                'Equipment',
                Icons.scuba_diving,
                Colors.orange,
                17,
              ),
              _buildCategoryCard(
                'Certification',
                Icons.card_membership,
                Colors.purple,
                8,
              ),
              _buildCategoryCard(
                'Dive Sites',
                Icons.beach_access,
                Colors.teal,
                12,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    Color color,
    int count,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          // Navigate to category
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                '$count discussions',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentDiscussionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Discussions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildDiscussionItem(
          title: 'Tips for diving in strong currents?',
          authorName: 'Alex Johnson',
          authorRole: 'Student',
          time: '2 hours ago',
          replies: 8,
          views: 42,
          category: 'Safety',
          categoryColor: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildDiscussionItem(
          title: 'Looking for dive buddies in the Florida Keys this weekend',
          authorName: 'Sarah Williams',
          authorRole: 'Student',
          time: '5 hours ago',
          replies: 12,
          views: 65,
          category: 'Dive Sites',
          categoryColor: Colors.teal,
        ),
        const SizedBox(height: 12),
        _buildDiscussionItem(
          title: 'Best regulators for cold water diving?',
          authorName: 'Michael Lee',
          authorRole: 'Student',
          time: '1 day ago',
          replies: 15,
          views: 120,
          category: 'Equipment',
          categoryColor: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildDiscussionItem(
          title: 'How to properly set up your BCD for maximum comfort',
          authorName: 'Jane Smith',
          authorRole: 'Instructor',
          time: '2 days ago',
          replies: 23,
          views: 187,
          category: 'Equipment',
          categoryColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildDiscussionItem({
    required String title,
    required String authorName,
    required String authorRole,
    required String time,
    required int replies,
    required int views,
    required String category,
    required Color categoryColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to discussion detail
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        authorRole == 'Instructor'
                            ? Colors.blue
                            : Colors.orange,
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    authorName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          authorRole == 'Instructor'
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      authorRole,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            authorRole == 'Instructor'
                                ? Colors.blue
                                : Colors.orange,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(fontSize: 12, color: categoryColor),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.forum, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$replies',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$views',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsTab() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildQuestionItem(
                question: 'How do I properly equalize my ears during descent?',
                authorName: 'Emily Chen',
                time: '3 hours ago',
                isAnswered: true,
                answers: 4,
                votes: 12,
                course: 'Diving Safety and Awareness',
              ),
              const SizedBox(height: 16),
              _buildQuestionItem(
                question:
                    'What\'s the difference between a wetsuit and a drysuit?',
                authorName: 'Michael Brown',
                time: '1 day ago',
                isAnswered: true,
                answers: 5,
                votes: 15,
                course: 'Advanced Scuba Techniques',
              ),
              const SizedBox(height: 16),
              _buildQuestionItem(
                question: 'How to handle a free-flowing regulator underwater?',
                authorName: 'David Wilson',
                time: '2 days ago',
                isAnswered: false,
                answers: 2,
                votes: 5,
                course: 'Diving Safety and Awareness',
              ),
              const SizedBox(height: 16),
              _buildQuestionItem(
                question: 'Best practices for underwater navigation?',
                authorName: 'Sarah Johnson',
                time: '3 days ago',
                isAnswered: true,
                answers: 8,
                votes: 20,
                course: 'Advanced Scuba Techniques',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionItem({
    required String question,
    required String authorName,
    required String time,
    required bool isAnswered,
    required int answers,
    required int votes,
    required String course,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to question detail
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.orange,
                    backgroundImage: const AssetImage(
                      'lib/assets/images/profile.jpg',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    authorName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Course: $course',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (isAnswered) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Answered',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.help_outline,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Open',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$answers',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$votes',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return Column(
      children: [
        _buildSearchBar(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              _buildFilterChip('All', true),
              _buildFilterChip('Instructors', false),
              _buildFilterChip('Students', false),
              _buildFilterChip('Unread', false),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildMessageItem(
                name: 'Jane Smith',
                role: 'Instructor',
                lastMessage:
                    'That\'s a good question! Let me explain how the Provider package works in Flutter...',
                time: '10:35 AM',
                isUnread: true,
                unreadCount: 2,
              ),
              const SizedBox(height: 12),
              _buildMessageItem(
                name: 'Study Group',
                role: 'Group',
                lastMessage:
                    'Sarah: Does anyone want to meet up for the group project on Saturday?',
                time: 'Yesterday',
                isUnread: true,
                unreadCount: 5,
              ),
              const SizedBox(height: 12),
              _buildMessageItem(
                name: 'Michael Johnson',
                role: 'Student',
                lastMessage: 'Thanks for your help with the assignment!',
                time: '2 days ago',
                isUnread: false,
                unreadCount: 0,
              ),
              const SizedBox(height: 12),
              _buildMessageItem(
                name: 'David Chen',
                role: 'Instructor',
                lastMessage:
                    'Your project submission has been reviewed. Great work!',
                time: '3 days ago',
                isUnread: false,
                unreadCount: 0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          // Handle filter selection
        },
        selectedColor: Colors.blue.withOpacity(0.2),
        checkmarkColor: Colors.blue,
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildMessageItem({
    required String name,
    required String role,
    required String lastMessage,
    required String time,
    required bool isUnread,
    required int unreadCount,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to message detail
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    role == 'Instructor'
                        ? Colors.blue
                        : role == 'Group'
                        ? Colors.purple
                        : Colors.orange,
                child:
                    role == 'Group'
                        ? const Icon(Icons.group, color: Colors.white)
                        : const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                role == 'Instructor'
                                    ? Colors.blue.withOpacity(0.2)
                                    : role == 'Group'
                                    ? Colors.purple.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  role == 'Instructor'
                                      ? Colors.blue
                                      : role == 'Group'
                                      ? Colors.purple
                                      : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage,
                      style: TextStyle(
                        color: isUnread ? Colors.black : Colors.grey[600],
                        fontWeight:
                            isUnread ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  if (isUnread)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewForumPostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final categoryController = TextEditingController();
        final titleController = TextEditingController();
        final contentController = TextEditingController();

        return AlertDialog(
          title: const Text('Create Forum Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'General', child: Text('General')),
                    DropdownMenuItem(
                      value: 'Course Help',
                      child: Text('Course Help'),
                    ),
                    DropdownMenuItem(
                      value: 'Projects',
                      child: Text('Projects'),
                    ),
                    DropdownMenuItem(value: 'Career', child: Text('Career')),
                    DropdownMenuItem(value: 'Social', child: Text('Social')),
                  ],
                  onChanged: (value) {
                    categoryController.text = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Create new forum post
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Forum post created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  void _showNewQuestionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final courseController = TextEditingController();
        final questionController = TextEditingController();

        return AlertDialog(
          title: const Text('Ask a Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Flutter Development Masterclass',
                      child: Text('Flutter Development Masterclass'),
                    ),
                    DropdownMenuItem(
                      value: 'Python for Data Science',
                      child: Text('Python for Data Science'),
                    ),
                    DropdownMenuItem(
                      value: 'Web Development with React',
                      child: Text('Web Development with React'),
                    ),
                    DropdownMenuItem(
                      value: 'UI/UX Design Fundamentals',
                      child: Text('UI/UX Design Fundamentals'),
                    ),
                  ],
                  onChanged: (value) {
                    courseController.text = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: 'Your Question',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Ask new question
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Question posted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ask'),
            ),
          ],
        );
      },
    );
  }

  void _showNewMessageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final receiverController = TextEditingController();
        final messageController = TextEditingController();

        return AlertDialog(
          title: const Text('New Message'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: receiverController,
                  decoration: const InputDecoration(
                    labelText: 'To',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Send new message
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message sent successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
}
