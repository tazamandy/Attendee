import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/verify_email_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Attendee App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/student-dashboard': (context) => const StudentDashboard(),
          '/admin-dashboard': (context) => const AdminDashboard(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/verify') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => VerifyEmailScreen(
                email: args?['email']?.toString() ?? '',
                studentId: args?['studentId']?.toString(),
                isPasswordReset: args?['isPasswordReset'] as bool? ?? false,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    // Show loading indicator while checking auth state
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (currentUser != null) {
      // Safely access map properties
      final isVerified = currentUser['isVerified'] as bool? ?? false;
      final email = currentUser['email'] as String? ?? '';
      final studentId = currentUser['studentId'] as String?;
      final role = currentUser['role'] as String? ?? 'student';

      if (!isVerified) {
        return VerifyEmailScreen(
          email: email,
          studentId: studentId,
        );
      }

      if (role == 'student') {
        return const StudentDashboard();
      } else if (role == 'admin') {
        return const AdminDashboard();
      }
    }

    return const LoginScreen();
  }
}