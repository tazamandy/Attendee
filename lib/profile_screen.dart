import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import 'screens/my_qr_code_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
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
                      '${(user?.firstName ?? '?')[0]}${(user?.lastName ?? '?')[0]}',
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${user?.firstName} ${user?.lastName}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: user?.qrCodeData != null
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MyQRCodeScreen(),
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
            SizedBox(height: 30),

            // Personal Information
            Text(
              'Personal Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildInfoCard(context, user),

            SizedBox(height: 20),

            // Account Status
            _buildStatusCard(context, user),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('User ID', user?.userId ?? ''),
            _buildInfoRow('Username', user?.username ?? ''),
            _buildInfoRow('Course', user?.course ?? ''),
            _buildInfoRow('Year Level', user?.yearLevel ?? ''),
            _buildInfoRow('Role', user?.role ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              user?.isVerified == true ? Icons.verified : Icons.pending,
              color: user?.isVerified == true ? Colors.green : Colors.orange,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.isVerified == true
                        ? 'Verified Account'
                        : 'Pending Verification',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.isVerified == true
                        ? 'Your account has been verified'
                        : 'Please verify your email address',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (user?.isVerified != true)
              TextButton(
                onPressed: () {
                  // Implement resend verification
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Verification email sent!')),
                  );
                },
                child: Text('Resend'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
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
