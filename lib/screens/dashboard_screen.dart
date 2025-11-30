import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../profile_screen.dart';
import '../qr_code_screen.dart';
// Remove EventsScreen import since it doesn't exist yet

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
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
                    'Welcome back,',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getUserName(user),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (_getCourse(user).isNotEmpty)
                        _buildInfoChip('🎓 ${_getCourse(user)}'),
                      if (_getYearLevel(user).isNotEmpty)
                        _buildInfoChip('📚 ${_getYearLevel(user)}'),
                      _buildInfoChip(
                        '👤 ${_getRole(user).toUpperCase()}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Quick Actions Grid
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardItem(
                    'My QR Code',
                    Icons.qr_code_2_rounded,
                    Colors.blue,
                    'Access your digital ID',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QrCodeScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardItem(
                    'Events',
                    Icons.event_rounded,
                    Colors.green,
                    'Browse campus events',
                    () {
                      _showComingSoon(context, message: 'Events feature coming soon!');
                    },
                  ),
                  _buildDashboardItem(
                    'Profile',
                    Icons.person_rounded,
                    Colors.orange,
                    'Manage your account',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  if (_isAdmin(user))
                    _buildDashboardItem(
                      'Admin Panel',
                      Icons.admin_panel_settings_rounded,
                      Colors.red,
                      'Manage system settings',
                      () {
                        _showComingSoon(context);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Safe property access methods
  String _getUserName(dynamic user) {
    if (user == null) return 'User!';
    
    try {
      final dynamicUser = user as dynamic;
      final firstName = dynamicUser.firstName ?? dynamicUser.first_name ?? '';
      final lastName = dynamicUser.lastName ?? dynamicUser.last_name ?? '';
      
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim() + '!';
      }
      
      return 'User!';
    } catch (e) {
      return 'User!';
    }
  }

  String _getCourse(dynamic user) {
    if (user == null) return '';
    
    try {
      final dynamicUser = user as dynamic;
      return dynamicUser.course?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  String _getYearLevel(dynamic user) {
    if (user == null) return '';
    
    try {
      final dynamicUser = user as dynamic;
      final yearLevel = dynamicUser.yearLevel ?? dynamicUser.year_level;
      return yearLevel?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  String _getRole(dynamic user) {
    if (user == null) return 'student';
    
    try {
      final dynamicUser = user as dynamic;
      return dynamicUser.role?.toString() ?? 'student';
    } catch (e) {
      return 'student';
    }
  }

  bool _isAdmin(dynamic user) {
    if (user == null) return false;
    
    try {
      final dynamicUser = user as dynamic;
      final role = dynamicUser.role?.toString().toLowerCase() ?? '';
      return role == 'admin' || role == 'superadmin';
    } catch (e) {
      return false;
    }
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDashboardItem(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              // Navigate to login screen or handle logout navigation
              Navigator.pushNamedAndRemoveUntil(
                context, 
                '/login', 
                (route) => false
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, {String message = 'Coming soon!'}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      )
    );
  }
}