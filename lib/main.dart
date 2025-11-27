import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/my_qr_code_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/verify_user_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,

        // 🔥 IMPORTANT: Add routes here
        routes: {
          '/': (context) => const _AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot': (context) => const ForgotPasswordScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/student_dashboard': (context) => const StudentDashboard(),
          '/admin_dashboard': (context) => const AdminDashboard(),
          '/qr': (context) => const MyQRCodeScreen(),
          '/reset_password': (context) => const ResetPasswordScreen(),
          '/verify': (context) => VerifyUserScreen(tempUserId: 'TEMP_USER_ID'),

        },

        // optional pero maganda meron:
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          );
        },
      ),
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // TEMPORARY
        return const LoginScreen();
      },
    );
  }
}
