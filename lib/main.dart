import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/forgot_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/reset_password_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Attendify',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF8F9FE),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/student-dashboard': (context) => const StudentDashboard(),
          '/admin-dashboard': (context) => const AdminDashboard(),
        },
 
        onGenerateRoute: (settings) {
          // Handle verify-email with dynamic email parameter
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
          
          // ✅ UPDATED: Handle reset-password route with only studentId and email
          if (settings.name == '/reset-password') {
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null) {
              // Fallback to login if no arguments provided
              return MaterialPageRoute(builder: (context) => const LoginScreen());
            }
            return MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                studentId: args['studentId'] ?? '',
                email: args['email'] ?? '',
                // ❌ REMOVED: token parameter since we get it from AuthProvider
              ),
            );
          }
          
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}