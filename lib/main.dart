import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/verify_email_screen.dart';
import 'screens/superadmin/superadmin_dashboard.dart';

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
          '/superadmin-dashboard': (context) => const SuperAdminDashboard(), // NEW
          '/verify-email': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            return VerifyEmailScreen(
              email: args?['email']?.toString() ?? '',
              studentId: args?['studentId']?.toString() ?? '',
              isPasswordReset: args?['isPasswordReset'] as bool? ?? false,
            );
          },
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUserData();
    setState(() {
      _isInitializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (_isInitializing || authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentUser != null) {
      final isVerified = currentUser['is_verified'] as bool? ?? 
                        currentUser['isVerified'] as bool? ?? 
                        currentUser['verified'] as bool? ?? 
                        false;
      final email = currentUser['email'] as String? ?? '';
      final studentId = currentUser['student_id'] as String? ?? 
                       currentUser['studentId'] as String? ?? 
                       '';
      final role = currentUser['role'] as String? ?? 'student';

      print('🔐 AUTH WRAPPER - User logged in:');
      print('   Role: $role');
      print('   Verified: $isVerified');

      if (!isVerified) {
        return VerifyEmailScreen(
          email: email,
          studentId: studentId,
          isPasswordReset: false,
        );
      }

      // ENHANCED: Route based on role
      if (role == 'superadmin') {
        print('👑 AUTH WRAPPER - Redirecting to superadmin dashboard');
        return const SuperAdminDashboard();
      } else if (role == 'admin') {
        print('👨‍💼 AUTH WRAPPER - Redirecting to admin dashboard');
        return const AdminDashboard();
      } else {
        print('🎓 AUTH WRAPPER - Redirecting to student dashboard');
        return const StudentDashboard();
      }
    }

    print('🔐 AUTH WRAPPER - No user logged in, redirecting to login');
    return const LoginScreen();
  }
}