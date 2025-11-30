import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart'; // <-- your real provider
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/verify_email_screen.dart';

void main() {
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
        // You can add more providers here in the future
      ],
      child: MaterialApp(
        title: 'Attendee App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),

        // Initial route handled by AuthWrapper
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
                email: args?['email'] ?? '',
                studentId: args?['studentId'],
                isPasswordReset: args?['isPasswordReset'] ?? false,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

// ----------------- AuthWrapper -----------------
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      // If the user is not verified, go to verify email screen
      if (!currentUser.isVerified) {
        return VerifyEmailScreen(
          email: currentUser.email,
          studentId: currentUser.studentId,
        );
      }

      // Navigate to dashboard based on role
      if (currentUser.role == 'student') {
        return const StudentDashboard();
      } else if (currentUser.role == 'admin') {
        return const AdminDashboard();
      }
    }

    // If no user logged in, show login screen
    return const LoginScreen();
  }
}
