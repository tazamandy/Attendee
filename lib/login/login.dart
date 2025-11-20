import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:postgres/postgres.dart';
import 'package:crypto/crypto.dart'; // For PBKDF2 hashing
import 'package:shared_preferences/shared_preferences.dart'; // For sessions
import 'dart:convert'; // For utf8
import 'dart:typed_data'; // For Uint8List

// PostgreSQL connection (replace with your URI)
const String postgresUri = 'postgres://user:pass@host:5432/dbname';

// Helper to parse URI
Map<String, String> parsePostgresUri(String uri) {
  final regex = RegExp(r'postgres://([^:]+):([^@]+)@([^:]+):(\d+)/(.+)');
  final match = regex.firstMatch(uri);
  if (match == null) throw Exception('Invalid PostgreSQL URI');
  return {
    'username': match.group(1)!,
    'password': match.group(2)!,
    'host': match.group(3)!,
    'port': match.group(4)!,
    'database': match.group(5)!,
  };
}

final Map<String, String> connParams = parsePostgresUri(postgresUri);

final PostgreSQLConnection db = PostgreSQLConnection(
  connParams['host']!,
  int.parse(connParams['port']!),
  connParams['database']!,
  username: connParams['username']!,
  password: connParams['password']!,
  useSSL: false, // Set to false for local dev; true for hosted
);

// ResponsiveHelper
class ResponsiveHelper {
  static double screenWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 414 ? 414 : width;
  }

  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static double fontScale(BuildContext context, double baseSize) =>
      baseSize * (ResponsiveHelper.screenWidth(context) / 375);
  static double paddingScale(BuildContext context, double basePadding) =>
      basePadding * (ResponsiveHelper.screenWidth(context) / 375);
}

// WebOnlyMessage
class WebOnlyMessage extends StatelessWidget {
  final String message;
  const WebOnlyMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.paddingScale(context, 20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android, size: 64, color: Colors.grey),
            SizedBox(height: ResponsiveHelper.paddingScale(context, 16)),
            Text(
              message,
              style: TextStyle(fontSize: ResponsiveHelper.fontScale(context, 18), fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.paddingScale(context, 8)),
            Text(
              'Connect your Android device via USB with debugging enabled and run `flutter run`.',
              style: TextStyle(fontSize: ResponsiveHelper.fontScale(context, 14), color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Auth Functions (unchanged except minor fixes)
Future<String?> signUp(String email, String password, Map<String, String> profileData) async {
  try {
    await db.open();
    final salt = utf8.encode('fixed_salt_for_demo');
    final key = generateKey(password, salt);
    final hash = base64.encode(key);

    final userResult = await db.query(
      'INSERT INTO users (email, password_hash) VALUES (@email, @hash) RETURNING id',
      substitutionValues: {'email': email, 'hash': hash},
    );
    final userId = userResult[0][0] as int;

    await db.execute(
      'INSERT INTO profiles (id, first_name, last_name, middle_name, course, year_level, section, department, college, contact, username, address) VALUES (@id, @first, @last, @middle, @course, @year, @section, @dept, @college, @contact, @user, @addr)',
      substitutionValues: {
        'id': userId,
        'first': profileData['first_name']!,
        'last': profileData['last_name']!,
        'middle': profileData['middle_name'] ?? '',
        'course': profileData['course']!,
        'year': profileData['year_level']!,
        'section': profileData['section']!,
        'dept': profileData['department']!,
        'college': profileData['college']!,
        'contact': profileData['contact']!,
        'user': profileData['username']!,
        'addr': profileData['address']!,
      },
    );
    await db.close();
    return userId.toString();
  } catch (e) {
    await db.close();
    print('Signup error: $e');
    rethrow;
  }
}

Future<String?> signIn(String email, String password) async {
  try {
    await db.open();
    final result = await db.query(
      'SELECT id, password_hash FROM users WHERE email = @email',
      substitutionValues: {'email': email},
    );
    if (result.isEmpty) throw Exception('User not found');
    final userId = result[0][0] as int;
    final storedHash = result[0][1] as String;

    final salt = utf8.encode('fixed_salt_for_demo');
    final key = generateKey(password, salt);
    final inputHash = base64.encode(key);

    if (storedHash != inputHash) throw Exception('Invalid password');

    final verifiedResult = await db.query(
      'SELECT verified FROM users WHERE id = @id',
      substitutionValues: {'id': userId},
    );
    final isVerified = verifiedResult[0][0] as bool;
    if (!isVerified) throw Exception('Please verify your email first (toggle manually in DB for demo)');

    await db.close();
    return userId.toString();
  } catch (e) {
    await db.close();
    print('Signin error: $e');
    rethrow;
  }
}

List<int> generateKey(String password, List<int> salt, {int iterations = 10000, int keyLength = 32}) {
  final keyBytes = utf8.encode(password);
  const int hLen = 32;
  final int blocks = (keyLength + hLen - 1) ~/ hLen;
  final List<int> dk = [];

  for (int i = 1; i <= blocks; i++) {
    final block = List<int>.from(salt);
    block.addAll([(i >> 24) & 0xFF, (i >> 16) & 0xFF, (i >> 8) & 0xFF, i & 0xFF]);

    var u = Hmac(sha256, keyBytes).convert(block).bytes;
    var t = List<int>.from(u);

    for (int j = 1; j < iterations; j++) {
      u = Hmac(sha256, keyBytes).convert(Uint8List.fromList(u)).bytes;
      for (int k = 0; k < t.length && k < u.length; k++) {
        t[k] ^= u[k];
      }
    }

    dk.addAll(t);
  }

  return dk.sublist(0, keyLength);
}

// Session helpers (unchanged)
Future<String?> getCurrentUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_id');
}

Future<void> saveUserId(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_id', userId);
}

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('user_id');
}

// Other functions (verifyUser, resetPassword, createEvent, fetchAttendance, fetchStats, recordAttendance) - unchanged from your code
Future<void> verifyUser(String userId) async {
  try {
    await db.open();
    final rowsAffected = await db.execute(
      'UPDATE users SET verified = true WHERE id = @id',
      substitutionValues: {'id': int.parse(userId)},
    );
    if (rowsAffected == 0) throw Exception('User not found');
    await db.close();
  } catch (e) {
    await db.close();
    print('Verify error: $e');
    rethrow;
  }
}

Future<void> resetPassword(String email, String newPassword) async {
  try {
    await db.open();
    final salt = utf8.encode('fixed_salt_for_demo');
    final key = generateKey(newPassword, salt);
    final hash = base64.encode(key);
    final rowsAffected = await db.execute(
      'UPDATE users SET password_hash = @hash WHERE email = @email',
      substitutionValues: {'hash': hash, 'email': email},
    );
    if (rowsAffected == 0) throw Exception('Email not found');
    await db.close();
  } catch (e) {
    await db.close();
    print('Reset error: $e');
    rethrow;
  }
}

Future<void> createEvent(String title, DateTime date, String description, String userId) async {
  try {
    await db.open();
    await db.execute(
      'INSERT INTO events (title, date, description, created_by) VALUES (@title, @date, @desc, @user)',
      substitutionValues: {
        'title': title,
        'date': date.toIso8601String().split('T')[0],
        'desc': description,
        'user': int.parse(userId),
      },
    );
    await db.close();
  } catch (e) {
    await db.close();
    print('Create event error: $e');
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> fetchAttendance() async {
  try {
    await db.open();
    final result = await db.query('''
      SELECT a.id, a.user_id, a.event_id, a.scanned_by, a.timestamp, 
             p.first_name, p.last_name, e.title, e.date 
      FROM attendance a 
      JOIN profiles p ON a.user_id = p.id 
      JOIN events e ON a.event_id = e.id 
      ORDER BY a.timestamp DESC
    ''');
    await db.close();
    return result.map((row) => row.toColumnMap()).toList();
  } catch (e) {
    await db.close();
    print('Fetch attendance error: $e');
    rethrow;
  }
}

Future<Map<String, int>> fetchStats() async {
  try {
    await db.open();
    final userCountResult = await db.query('SELECT COUNT(*) FROM profiles');
    final eventCountResult = await db.query('SELECT COUNT(*) FROM events');
    final attCountResult = await db.query('SELECT COUNT(*) FROM attendance');

    final userCount = userCountResult[0][0] as int;
    final eventCount = eventCountResult[0][0] as int;
    final attCount = attCountResult[0][0] as int;

    await db.close();
    return {'users': userCount, 'events': eventCount, 'attendance': attCount};
  } catch (e) {
    await db.close();
    print('Fetch stats error: $e');
    rethrow;
  }
}

Future<void> recordAttendance(String username, String scannerUserId) async {
  try {
    await db.open();
    final profileResult = await db.query(
        'SELECT id FROM profiles WHERE username = @user',
        substitutionValues: {'user': username});
    if (profileResult.isEmpty) throw Exception('User not found');
    final profileId = profileResult[0][0] as int;

    final eventResult = await db.query('SELECT id FROM events ORDER BY created_at DESC LIMIT 1');
    if (eventResult.isEmpty) throw Exception('No events available');
    final eventId = eventResult[0][0] as int;

    await db.execute(
      'INSERT INTO attendance (user_id, event_id, scanned_by) VALUES (@profile, @event, @scanner)',
      substitutionValues: {
        'profile': profileId,
        'event': eventId,
        'scanner': int.parse(scannerUserId),
      },
    );
    await db.close();
  } catch (e) {
    await db.close();
    print('Record attendance error: $e');
    rethrow;
  }
}

// SplashScreen (fixed const route)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      final userId = await getCurrentUserId();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => userId != null ? const AdminScreen() : const LoginScreen1()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: kIsWeb
          ? const WebOnlyMessage(
              message: 'This app is designed for mobile devices. Please connect your Android phone with USB debugging enabled.',
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      boxShadow: [
                        BoxShadow(color: Colors.cyan.withOpacity(0.5), blurRadius: 20, spreadRadius: 0),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.access_time_filled, size: 80, color: Colors.cyanAccent),
                        Positioned(top: 40, left: 20, child: Container(width: 12, height: 4, color: Colors.cyanAccent)),
                        const Positioned(bottom: 20, left: 25, child: Icon(Icons.check, size: 20, color: Colors.cyanAccent)),
                        const Positioned(bottom: 20, right: 25, child: Icon(Icons.check, size: 20, color: Colors.cyanAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// LoginScreen1 (fixed const routes)
class LoginScreen1 extends StatefulWidget {
  const LoginScreen1({super.key});

  @override
  State<LoginScreen1> createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginScreen1> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login disabled on web. Connect mobile device with USB debugging.')),
        );
      }
      return;
    }
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email and password.')));
      }
      return;
    }
    try {
      final userId = await signIn(_emailController.text.trim(), _passwordController.text);
      if (userId == null) throw Exception('Login failed');
      await saveUserId(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login successful!')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
      }
    }
  }

  Future<void> _forgotPassword() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset disabled on web. Connect mobile device.')),
        );
      }
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your email first.')));
      }
      return;
    }
    final newPass = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Enter new password'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) Navigator.pop(context, controller.text);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (newPass != null && newPass.isNotEmpty) {
      try {
        await resetPassword(_emailController.text.trim(), newPass);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset!')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reset failed: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(body: const WebOnlyMessage(message: 'Please connect your Android device via USB with debugging enabled to use this app.'));
    }
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 414),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(ResponsiveHelper.paddingScale(context, 24)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: ResponsiveHelper.screenHeight(context) - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Log In',
                            style: TextStyle(fontSize: ResponsiveHelper.fontScale(context, 32), fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: ResponsiveHelper.paddingScale(context, 32)),
                          const Text('Email', style: TextStyle(fontSize: 16)),
                          SizedBox(height: ResponsiveHelper.paddingScale(context, 8)),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'example@email.com',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: ResponsiveHelper.paddingScale(context, 16)),
                          const Text('Password', style: TextStyle(fontSize: 16)),
                          SizedBox(height: ResponsiveHelper.paddingScale(context, 8)),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.paddingScale(context, 8)),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: Text(
                                'Forgot Password',
                                style: TextStyle(fontSize: ResponsiveHelper.fontScale(context, 14), color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.paddingScale(context, 32)),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _signIn,
                              child: Text('Log In', style: TextStyle(fontSize: ResponsiveHelper.fontScale(context, 16))),
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.paddingScale(context, 16)),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                              child: Text(
                                'Don\'t have an account? Sign up',
                                style: TextStyle(fontSize: ResponsiveHelper.fontScale(context, 14), color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// SignUpScreen (fixed const route)
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (kIsWeb) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signup disabled on web.')));
      return;
    }
    try {
      final profileData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'username': _usernameController.text,
        'course': 'Sample Course', // Add real controller
        'year_level': '1',
        'section': 'A',
        'department': 'Sample Dept',
        'college': 'Sample College',
        'contact': '1234567890',
        'address': 'Sample Address',
        'middle_name': '',
      };
      final userId = await signUp(_emailController.text.trim(), _passwordController.text, profileData);
      if (userId != null) {
        await saveUserId(userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signup successful! Please verify email (manual in DB).')));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VerificationScreen()));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: kIsWeb
          ? const WebOnlyMessage(message: 'Signup disabled on web.')
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                    TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password'), validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 chars' : null),
                    TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                    TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                    TextFormField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                    // Add more fields...
                    ElevatedButton(onPressed: _signUp, child: const Text('Sign Up')),
                  ],
                ),
              ),
            ),
    );
  }
}

// VerificationScreen (fixed const route, added manual verify)
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isVerifying = false;

  Future<void> _manualVerify() async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user session found.')));
      return;
    }
    setState(() => _isVerifying = true);
    try {
      await verifyUser(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verified manually! You can now login.')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen1()));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verify failed: $e')));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Verification')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text('Check your email for verification link (simulated).'),
              const SizedBox(height: 8),
              const Text('For demo: Use the button below to manually verify.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isVerifying ? null : _manualVerify,
                child: _isVerifying
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    : const Text('Manual Verify (Demo)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AdminScreen (fixed const routes)
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final stats = await fetchStats();
      if (mounted) setState(() { _stats = stats; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stats load failed: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await logout();
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen1()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Dashboard Stats', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Card(child: Column(children: [const Text('Users'), Text('${_stats['users']}')])),
                      Card(child: Column(children: [const Text('Events'), Text('${_stats['events']}')])),
                      Card(child: Column(children: [const Text('Attendance'), Text('${_stats['attendance']}')])),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateEventScreen())),
                    child: const Text('Create Event'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceScreen())),
                    child: const Text('View Attendance'),
                  ),
                ],
              ),
            ),
    );
  }
}

// CreateEventScreen (fixed const route)
class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _createEvent() async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user session. Please login.')));
      return;
    }
    try {
      await createEvent(_titleController.text, _selectedDate, _descriptionController.text, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event created!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
            ListTile(title: Text('Date: ${_selectedDate.toString().split(' ')[0]}'), trailing: const Icon(Icons.calendar_today), onTap: _selectDate),
            ElevatedButton(onPressed: _createEvent, child: const Text('Create')),
          ],
        ),
      ),
    );
  }
}

// AttendanceScreen (unchanged)
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Records')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAttendance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final data = snapshot.data ?? [];
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return ListTile(
                title: Text('${item['first_name']} ${item['last_name']}'),
                subtitle: Text('${item['title']} - ${item['timestamp']}'),
              );
            },
          );
        },
      ),
    );
  }
}

// Main App (unchanged)
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendee App',
      theme: ThemeData(primarySwatch: Colors.cyan),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}