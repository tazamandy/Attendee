import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import 'qr_code_dialog.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get authentication provider and current user
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final size = MediaQuery.of(context).size;

    // Get student ID once to avoid multiple calls
    final studentId = _getStudentId(user);

    // Debug: Print user data to console for troubleshooting
    if (user != null) {
      print('🎯 STUDENT DASHBOARD DEBUG INFO 🎯');
      print('First Name: ${user.firstName}');
      print('Last Name: ${user.lastName}');
      print('Email: ${user.email}');
      print('Course: ${user.course}');
      print('Year Level: ${user.yearLevel}');
      print('Final Student ID: $studentId');
      print('User Type: ${user.runtimeType}');
      print('User Object: $user');
      print('🎯 END DEBUG INFO 🎯');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with welcome message and logout
                _buildHeader(context, authProvider, user),
                const SizedBox(height: 32),

                // Profile Overview Card with user information
                _buildProfileOverview(user, studentId),
                const SizedBox(height: 24),

                // Quick Actions Section with navigation options
                _buildQuickActionsSection(context, user, studentId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FIXED: Method to extract student ID from user object
String _getStudentId(dynamic user) {
  if (user == null) return 'Not Available';
  
  print('🔍 SEARCHING FOR STUDENT ID...');
  print('📊 User Object Type: ${user.runtimeType}');

  // METHOD 1: Try to convert to JSON and search all properties
  try {
    if (user.toJson != null) {
      final userJson = user.toJson();
      print('📋 USER JSON KEYS: ${userJson.keys}');
      print('📋 FULL USER JSON: $userJson');
      
      // Search for student ID in all JSON properties
      for (var key in userJson.keys) {
        final value = userJson[key];
        if (value != null && value.toString().isNotEmpty) {
          print('🔎 Checking key: $key = $value');
          
          // If key contains "student" or "id", it might be our target
          if (key.toString().toLowerCase().contains('student') || 
              key.toString().toLowerCase().contains('id')) {
            print('🎯 POTENTIAL ID KEY: $key = $value');
            
            // Double check if this looks like a student ID
            final stringValue = value.toString();
            if (stringValue.contains('S2025') || 
                stringValue.length >= 6) {
              print('✅ CONFIRMED STUDENT ID: $key = $stringValue');
              return stringValue;
            }
          }
        }
      }
    }
  } catch (e) {
    print('❌ JSON conversion failed: $e');
  }

  // METHOD 2: Direct property access with better debugging
  final directProperties = [
    'studentId', 'student_id', 'id', 'userId', 'studentNumber',
    'studentID', 'code', 'studentCode', 'registrationNumber'
  ];

  print('🔧 DIRECT PROPERTY ACCESS...');
  for (var prop in directProperties) {
    try {
      final value = _getPropertySafely(user, prop);
      print('   $prop: $value');
      
      if (value != null && value.toString().isNotEmpty) {
        print('✅ FOUND: $prop = $value');
        return value.toString();
      }
    } catch (e) {
      print('   $prop: inaccessible');
    }
  }

  // METHOD 3: Dynamic reflection - try to access any property
  print('🔦 DYNAMIC PROPERTY SCAN...');
  try {
    // Try to access properties dynamically using reflection-like approach
    final dynamicUser = user as dynamic;
    
    // Common patterns for student IDs
    final possibleValues = [
      dynamicUser.studentId,
      dynamicUser.student_id, 
      dynamicUser.id,
      dynamicUser.userId,
      dynamicUser.studentNumber,
      dynamicUser.code,
    ];
    
    for (var value in possibleValues) {
      if (value != null && value.toString().isNotEmpty) {
        print('✅ DYNAMIC FOUND: $value');
        return value.toString();
      }
    }
  } catch (e) {
    print('❌ Dynamic access failed: $e');
  }

  // METHOD 4: Check if there's a student_info object
  print('📁 CHECKING STUDENT_INFO OBJECT...');
  try {
    final studentInfo = user.student_info;
    if (studentInfo != null) {
      print('📋 STUDENT_INFO: $studentInfo');
      
      if (studentInfo is Map) {
        for (var key in studentInfo.keys) {
          final value = studentInfo[key];
          if (value != null && value.toString().isNotEmpty) {
            print('🔎 student_info.$key = $value');
            
            if (key.toString().toLowerCase().contains('id') ||
                key.toString().toLowerCase().contains('student')) {
              print('✅ FOUND IN STUDENT_INFO: $key = $value');
              return value.toString();
            }
          }
        }
      }
    }
  } catch (e) {
    print('❌ student_info access failed: $e');
  }

  // FINAL FALLBACK: Return a generic message
  print('⚠️ STUDENT ID NOT FOUND IN ANY PROPERTY');
  print('💡 Check your User model class structure');
  return 'ID Not Found';
}
  // NEW: Debug method to analyze user properties
  void _debugUserProperties(dynamic user) {
    print('🔍 DEBUG USER PROPERTIES:');
    try {
      // Try to print all available properties
      final properties = ['studentId', 'student_id', 'id', 'studentId', 'email', 'firstName', 'lastName'];
      for (var prop in properties) {
        try {
          final value = _getPropertySafely(user, prop);
          print('   $prop: $value (type: ${value?.runtimeType})');
        } catch (e) {
          print('   $prop: NOT ACCESSIBLE');
        }
      }
      
      // Try to convert to map if possible
      if (user.toJson != null) {
        try {
          final json = user.toJson();
          print('   JSON: $json');
        } catch (e) {
          print('   JSON conversion failed: $e');
        }
      }
    } catch (e) {
      print('   Error debugging properties: $e');
    }
  }

 dynamic _getPropertySafely(dynamic obj, String propertyName) {
  try {
    // Try direct property access first for known property names
    switch (propertyName) {
      case 'id':
        return obj.id;
      case 'studentId':
        return obj.studentId;
      case 'student_id':
        return obj.student_id;
      case 'studentNumber':
        return obj.studentNumber;
      case 'studentID':
        return obj.studentID;
      case 'student_code':
        return obj.student_code;
      case 'code':
        return obj.code;
      case 'studentCode':
        return obj.studentCode;
      case 'registrationNumber':
        return obj.registrationNumber;
      case 'rollNumber':
        return obj.rollNumber;
      case 'student_no':
        return obj.student_no;
      case 'studentNo':
        return obj.studentNo;
      case 'userId':
        return obj.userId;
      case 'student_info':
        return obj.student_info;
      default:
        return null;
    }
  } catch (e) {
    // If direct access fails, try dynamic access as fallback
    try {
      return (obj as dynamic).$propertyName;
    } catch (e) {
      return null;
    }
  }
}

  // Builds the header section with welcome message and logout button
  Widget _buildHeader(BuildContext context, AuthProvider authProvider, dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Welcome message section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.firstName ?? 'Student',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D1F),
              ),
            ),
          ],
        ),
        // Logout button container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey[200]!,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _logoutAndGoToLogin(context, authProvider);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Builds the profile overview card with user information
  Widget _buildProfileOverview(dynamic user, String studentId) {
    // Use a more descriptive fallback for better UX
    final displayStudentId = studentId == 'N/A' 
      ? 'Not Available' 
      : studentId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF60B5FF), Color(0xFF3A8DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF60B5FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile avatar container
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user?.firstName?[0] ?? 'S',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF60B5FF),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User information section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.course ?? 'No Course',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Year level and student ID badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Year ${user?.yearLevel ?? 'N/A'} • ID: $displayStudentId',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Additional information cards section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn('Student ID', displayStudentId),
                _buildInfoColumn('Year Level', 'Year ${user?.yearLevel ?? 'N/A'}'),
                _buildInfoColumn('Course', user?.course ?? 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds individual information column for profile overview
  Widget _buildInfoColumn(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Builds the quick actions section with navigation options
  Widget _buildQuickActionsSection(BuildContext context, dynamic user, String studentId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1D1F),
          ),
        ),
        const SizedBox(height: 16),
        // Grid layout for action cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            // QR Code action card
            _buildActionCard(
              'QR Code',
              () {
                QRCodeDialog.show(
                  context,
                  user: user,
                  studentId: studentId,
                );
              },
            ),
            // Attendance action card
            _buildActionCard(
              'Attendance',
              () {},
            ),
            // Schedule action card
            _buildActionCard(
              'Schedule',
              () {},
            ),
            // Profile action card
            _buildActionCard(
              'Profile',
              () {},
            ),
          ],
        ),
      ],
    );
  }

  // Builds individual action card for quick actions
  Widget _buildActionCard(
    String title,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey[100]!,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF60B5FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '📱',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1D1F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Handles logout process with confirmation dialog
  void _logoutAndGoToLogin(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFF60B5FF),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D1F),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Logout confirmation button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF60B5FF)),
                                ),
                              );
                            },
                          );

                          // Perform logout
                          await authProvider.logout();

                          // Navigate to login screen and clear navigation stack
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF60B5FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQRCodeDialog(BuildContext context, dynamic user) {
    final studentId = _getStudentId(user);
    final qrData = _generateQRData(user, studentId);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Student QR Code',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D1F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan for attendance verification',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                
                // QR Code
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[200]!,
                    ),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Student Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF60B5FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Student ID: $studentId',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user?.course ?? 'No Course'} • Year ${user?.yearLevel ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF60B5FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _generateQRData(dynamic user, String studentId) {
    final data = {
      'student_id': studentId,
      'first_name': user?.firstName ?? '',
      'last_name': user?.lastName ?? '',
      'email': user?.email ?? '',
      'course': user?.course ?? '',
      'year_level': user?.yearLevel?.toString() ?? '',
      'type': 'student_attendance',
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    
    return jsonEncode(data);
  }
}