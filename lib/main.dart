import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/student/dashboard_screen.dart';
import 'screens/student/courses_screen.dart';
import 'screens/student/marketplace_screen.dart';
import 'screens/student/course_detail_screen.dart';
import 'screens/student/grades_screen.dart';
import 'screens/student/certificates_screen.dart';
import 'screens/student/discussions_screen.dart';
import 'screens/student/profile_screen.dart';
import 'screens/student/calendar_screen.dart';
import 'screens/modules/content_navigator.dart';
import 'screens/modules/lesson_screen.dart';
import 'screens/modules/video_screen.dart';
import 'screens/modules/quiz_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/courses_screen.dart';
import 'screens/admin/create_course_screen.dart';
import 'screens/admin/edit_course_screen.dart';
import 'screens/admin/create_module_screen.dart';
import 'screens/admin/students_screen.dart';
import 'screens/admin/analytics_screen.dart';
import 'screens/admin/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Master Training',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.blue[50],
        appBarTheme: AppBarTheme(
          elevation: 2,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If Firebase is still initializing or checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If user is logged in
          if (snapshot.hasData && snapshot.data != null) {
            // You could add logic here to check if user is admin or student
            // For now, redirect to student dashboard
            return const StudentDashboardScreen();
          }

          // If user is not logged in
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/student_dashboard': (context) => const StudentDashboardScreen(),
        '/student_courses': (context) => const StudentCoursesScreen(),
        '/course_marketplace': (context) => const MarketplaceScreen(),
        '/course_detail': (context) => const CourseDetailScreen(),
        '/student_grades': (context) => const GradesScreen(),
        '/student_certificates': (context) => const CertificatesScreen(),
        '/student_discussions': (context) => const DiscussionsScreen(),
        '/student_profile': (context) => const StudentProfileScreen(),
        '/student_calendar': (context) => const CalendarScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/admin_courses': (context) => CoursesScreen(),
        '/admin_create_course': (context) => const CreateCourseScreen(),
        '/admin_create_module': (context) => const CreateModuleScreen(),
        '/admin_students': (context) => const StudentsScreen(),
        '/admin_analytics': (context) => const AnalyticsScreen(),
        '/admin_settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/admin_edit_course') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => EditCourseScreen(courseId: args['courseId']),
          );
        }
        return null;
      },
    );
  }
}
