// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'qr_code_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Text(
                      _getUserInitials(user),
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getUserName(user),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _getUserEmail(user),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _hasQRCode(user)
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const QrCodeScreen(),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.qr_code),
                    label: const Text('MY QR CODE'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Personal Information
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(context, user),

            const SizedBox(height: 20),

            // Account Status
            _buildStatusCard(context, user),
          ],
        ),
      ),
    );
  }

  String _getUserInitials(dynamic user) {
    if (user == null) return '?';
    
    try {
      String firstName = '';
      String lastName = '';
      
      if (user is Map<String, dynamic>) {
        firstName = user['firstName'] ?? user['first_name'] ?? '';
        lastName = user['lastName'] ?? user['last_name'] ?? '';
      } else {
        final dynamicUser = user as dynamic;
        firstName = dynamicUser.firstName ?? dynamicUser.first_name ?? '';
        lastName = dynamicUser.lastName ?? dynamicUser.last_name ?? '';
      }
      
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        return '${firstName[0]}${lastName[0]}';
      } else if (firstName.isNotEmpty) {
        return firstName[0];
      } else if (lastName.isNotEmpty) {
        return lastName[0];
      }
      
      final username = _getUsername(user);
      if (username.isNotEmpty) {
        return username[0];
      }
      
      return '?';
    } catch (e) {
      return '?';
    }
  }

  String _getUserName(dynamic user) {
    if (user == null) return 'Unknown User';
    
    try {
      String firstName = '';
      String lastName = '';
      
      if (user is Map<String, dynamic>) {
        firstName = user['firstName'] ?? user['first_name'] ?? '';
        lastName = user['lastName'] ?? user['last_name'] ?? '';
      } else {
        final dynamicUser = user as dynamic;
        firstName = dynamicUser.firstName ?? dynamicUser.first_name ?? '';
        lastName = dynamicUser.lastName ?? dynamicUser.last_name ?? '';
      }
      
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
      
      return _getUsername(user);
    } catch (e) {
      return 'Unknown User';
    }
  }

  String _getUserEmail(dynamic user) {
    if (user == null) return '';
    
    try {
      if (user is Map<String, dynamic>) {
        return user['email'] ?? '';
      }
      
      final dynamicUser = user as dynamic;
      return dynamicUser.email ?? '';
    } catch (e) {
      return '';
    }
  }

  String _getUsername(dynamic user) {
    if (user == null) return '';
    
    try {
      if (user is Map<String, dynamic>) {
        return user['username'] ?? '';
      }
      
      final dynamicUser = user as dynamic;
      return dynamicUser.username ?? '';
    } catch (e) {
      return '';
    }
  }

  bool _hasQRCode(dynamic user) {
    if (user == null) return false;
    
    try {
      String? qrCodeData;
      
      if (user is Map<String, dynamic>) {
        qrCodeData = user['qrCodeData'] ?? user['qr_code_data'];
      } else {
        final dynamicUser = user as dynamic;
        qrCodeData = dynamicUser.qrCodeData ?? dynamicUser.qr_code_data;
      }
      
      return qrCodeData != null && qrCodeData.toString().isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Widget _buildInfoCard(BuildContext context, dynamic user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('User ID', _getStudentId(user)),
            _buildInfoRow('Username', _getUsername(user)),
            _buildInfoRow('Course', _getCourse(user)),
            _buildInfoRow('Year Level', _getYearLevel(user)),
            _buildInfoRow('Role', _getRole(user)),
          ],
        ),
      ),
    );
  }

  String _getStudentId(dynamic user) {
    if (user == null) return '';
    
    try {
      if (user is Map<String, dynamic>) {
        return user['student_id']?.toString() ?? 
               user['studentId']?.toString() ?? 
               user['id']?.toString() ?? 
               user['userId']?.toString() ??
               '';
      }
      
      final dynamicUser = user as dynamic;
      return dynamicUser.student_id?.toString() ?? 
             dynamicUser.studentId?.toString() ?? 
             dynamicUser.id?.toString() ?? 
             dynamicUser.userId?.toString() ??
             '';
    } catch (e) {
      return '';
    }
  }

  String _getCourse(dynamic user) {
    if (user == null) return '';
    
    try {
      if (user is Map<String, dynamic>) {
        return user['course']?.toString() ?? '';
      }
      
      final dynamicUser = user as dynamic;
      return dynamicUser.course?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  String _getYearLevel(dynamic user) {
    if (user == null) return '';
    
    try {
      String? yearLevel;
      
      if (user is Map<String, dynamic>) {
        yearLevel = user['yearLevel'] ?? user['year_level'];
      } else {
        final dynamicUser = user as dynamic;
        yearLevel = dynamicUser.yearLevel ?? dynamicUser.year_level;
      }
      
      return yearLevel?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  String _getRole(dynamic user) {
    if (user == null) return '';
    
    try {
      if (user is Map<String, dynamic>) {
        return user['role'] ?? 'Student';
      }
      
      final dynamicUser = user as dynamic;
      return dynamicUser.role ?? 'Student';
    } catch (e) {
      return 'Student';
    }
  }

  Widget _buildStatusCard(BuildContext context, dynamic user) {
    final isVerified = _isUserVerified(user);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isVerified ? Icons.verified : Icons.pending,
              color: isVerified ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVerified ? 'Verified Account' : 'Pending Verification',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isVerified ? 'Your account has been verified' : 'Please verify your email address',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (!isVerified)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification email sent!')),
                  );
                },
                child: const Text('Resend'),
              ),
          ],
        ),
      ),
    );
  }

  bool _isUserVerified(dynamic user) {
    if (user == null) return false;
    
    try {
      if (user is Map<String, dynamic>) {
        return user['isVerified'] == true || 
               user['is_verified'] == true ||
               user['verified'] == true;
      }
      
      final dynamicUser = user as dynamic;
      return dynamicUser.isVerified == true || 
             dynamicUser.is_verified == true ||
             dynamicUser.verified == true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : 'Not provided',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}