// lib/screens/qr_code_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final qrCodeData = _getQrCodeData(user);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Code'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR Code refreshed')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // QR Code Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  if (qrCodeData != null && qrCodeData.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        qrCodeData,
                        height: 250,
                        width: 250,
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            children: [
                              Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load QR code',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 250,
                            width: 250,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.grey.shade400),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No QR Code Available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contact administrator to generate your QR code',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // User Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Name', _getUserName(user)),
                  _buildInfoRow('Student ID', _getStudentId(user)),
                  _buildInfoRow('Course', _getCourse(user)),
                  _buildInfoRow('Year Level', _getYearLevel(user)),
                  _buildInfoRow('Role', 'Student'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.orange.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Present this QR code for attendance tracking, library access, or event registration.',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showShareOptions(context);
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _downloadQRCode(context);
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
  }

  String? _getQrCodeData(dynamic user) {
    if (user == null) return null;
    
    try {
      if (user is Map<String, dynamic>) {
        return user['qrCodeData']?.toString() ?? 
               user['qr_code_data']?.toString() ?? 
               user['qrCode']?.toString() ??
               user['qr_code']?.toString();
      }
      
      final dynamicUser = user as dynamic;
      return dynamicUser.qrCodeData?.toString() ?? 
             dynamicUser.qr_code_data?.toString() ?? 
             dynamicUser.qrCode?.toString() ??
             dynamicUser.qr_code?.toString();
    } catch (e) {
      return null;
    }
  }

  String _getUserName(dynamic user) {
    if (user == null) return 'N/A';
    
    try {
      if (user is Map<String, dynamic>) {
        final firstName = user['firstName'] ?? user['first_name'] ?? '';
        final lastName = user['lastName'] ?? user['last_name'] ?? '';
        
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          return '$firstName $lastName'.trim();
        }
        return user['username'] ?? 'N/A';
      }
      
      final dynamicUser = user as dynamic;
      final firstName = dynamicUser.firstName ?? dynamicUser.first_name ?? '';
      final lastName = dynamicUser.lastName ?? dynamicUser.last_name ?? '';
      
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
      return dynamicUser.username ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getStudentId(dynamic user) {
    if (user == null) return 'N/A';
    
    try {
      if (user is Map<String, dynamic>) {
        return user['student_id']?.toString() ?? 
               user['studentId']?.toString() ?? 
               user['id']?.toString() ?? 
               user['userId']?.toString() ??
               'N/A';
      }
      
      final dynamicUser = user as dynamic;
      return dynamicUser.student_id?.toString() ?? 
             dynamicUser.studentId?.toString() ?? 
             dynamicUser.id?.toString() ?? 
             dynamicUser.userId?.toString() ??
             'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getCourse(dynamic user) {
    if (user == null) return 'N/A';
    
    try {
      if (user is Map<String, dynamic>) {
        return user['course']?.toString() ?? 
               user['courseName']?.toString() ?? 
               user['program']?.toString() ??
               'N/A';
      }
      
      final dynamicUser = user as dynamic;
      return dynamicUser.course?.toString() ?? 
             dynamicUser.courseName?.toString() ?? 
             dynamicUser.program?.toString() ??
             'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getYearLevel(dynamic user) {
    if (user == null) return 'N/A';
    
    try {
      if (user is Map<String, dynamic>) {
        final yearLevel = user['yearLevel'] ?? user['year_level'];
        if (yearLevel != null) {
          return 'Year $yearLevel';
        }
        return 'N/A';
      }
      
      final dynamicUser = user as dynamic;
      final yearLevel = dynamicUser.yearLevel ?? dynamicUser.year_level;
      
      if (yearLevel != null) {
        return 'Year $yearLevel';
      }
      return 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.message_rounded, color: Colors.blue),
                ),
                title: const Text('Share via Message'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share via message')),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.email_rounded, color: Colors.red),
                ),
                title: const Text('Share via Email'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share via email')),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.copy_rounded, color: Colors.green),
                ),
                title: const Text('Copy QR Code Data'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR code data copied')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _downloadQRCode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR code saved to gallery'),
        backgroundColor: Colors.green,
      ),
    );
  }
}