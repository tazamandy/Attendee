import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF007AFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('User Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF007AFF)),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value.toLowerCase());
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Students'),
                _buildFilterChip('Admins'),
                _buildFilterChip('Verified'),
                _buildFilterChip('Unverified'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = selected ? label : 'All');
        },
        backgroundColor: Colors.grey[100],
        selectedColor: const Color(0xFF007AFF).withOpacity(0.2),
        checkmarkColor: const Color(0xFF007AFF),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF007AFF) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUserList() {
    // TODO: Replace with actual user data from API
    final users = _getMockUsers();
    
    final filteredUsers = users.where((user) {
      final matchesSearch = user['name'].toLowerCase().contains(_searchQuery) ||
                          user['student_id'].toLowerCase().contains(_searchQuery);
      final matchesFilter = _selectedFilter == 'All' ||
                          (_selectedFilter == 'Students' && user['role'] == 'student') ||
                          (_selectedFilter == 'Admins' && user['role'] == 'admin') ||
                          (_selectedFilter == 'Verified' && user['is_verified']) ||
                          (_selectedFilter == 'Unverified' && !user['is_verified']);
      return matchesSearch && matchesFilter;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        return _buildUserCard(filteredUsers[index]);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF007AFF).withOpacity(0.1),
          radius: 28,
          child: Text(
            user['name'][0].toUpperCase(),
            style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w700, fontSize: 20),
          ),
        ),
        title: Text(
          user['name'],
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${user['student_id']}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: user['role'] == 'admin' 
                        ? const Color(0xFFFF3B30).withOpacity(0.1) 
                        : const Color(0xFF007AFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user['role'].toUpperCase(),
                    style: TextStyle(
                      color: user['role'] == 'admin' ? const Color(0xFFFF3B30) : const Color(0xFF007AFF),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (user['is_verified'])
                  const Icon(Icons.verified_rounded, color: Color(0xFF34C759), size: 16),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                children: const [
                  Icon(Icons.edit_rounded, size: 18),
                  SizedBox(width: 12),
                  Text('Edit User'),
                ],
              ),
              onTap: () => _showEditUserDialog(user),
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(
                    user['role'] == 'student' ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(user['role'] == 'student' ? 'Promote to Admin' : 'Demote to Student'),
                ],
              ),
              onTap: () => _toggleUserRole(user),
            ),
            PopupMenuItem(
              child: Row(
                children: const [
                  Icon(Icons.delete_rounded, size: 18, color: Color(0xFFFF3B30)),
                  SizedBox(width: 12),
                  Text('Delete User', style: TextStyle(color: Color(0xFFFF3B30))),
                ],
              ),
              onTap: () => _showDeleteConfirmation(user),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    // TODO: Implement edit user dialog
    Future.delayed(Duration.zero, () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edit user feature coming soon')),
      );
    });
  }

  void _toggleUserRole(Map<String, dynamic> user) {
    // TODO: Implement role toggle logic
    Future.delayed(Duration.zero, () {
      final newRole = user['role'] == 'student' ? 'admin' : 'student';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User promoted to $newRole'),
          backgroundColor: const Color(0xFF34C759),
        ),
      );
    });
  }

  void _showDeleteConfirmation(Map<String, dynamic> user) {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete User?'),
          content: Text('Are you sure you want to delete ${user['name']}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User deleted'),
                    backgroundColor: Color(0xFFFF3B30),
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Color(0xFFFF3B30))),
            ),
          ],
        ),
      );
    });
  }

  List<Map<String, dynamic>> _getMockUsers() {
    return [
      {'name': 'Juan Dela Cruz', 'student_id': '2021-0001', 'role': 'student', 'is_verified': true},
      {'name': 'Maria Santos', 'student_id': '2021-0002', 'role': 'student', 'is_verified': true},
      {'name': 'Admin User', 'student_id': 'ADMIN-001', 'role': 'admin', 'is_verified': true},
      {'name': 'Pedro Reyes', 'student_id': '2021-0003', 'role': 'student', 'is_verified': false},
      {'name': 'Ana Garcia', 'student_id': '2021-0004', 'role': 'student', 'is_verified': true},
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}


// lib/screens/superadmin/attendance_logs_screen.dart
class AttendanceLogsScreen extends StatelessWidget {
  const AttendanceLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF34C759),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Attendance Logs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_rounded, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildAttendanceLogCard(index);
        },
      ),
    );
  }

  Widget _buildAttendanceLogCard(int index) {
    // TODO: Replace with actual attendance data
    final mockData = {
      'name': 'Student ${index + 1}',
      'student_id': '2021-000${index + 1}',
      'time': '${8 + index}:${30 + index} AM',
      'date': 'Dec ${index + 1}, 2024',
      'status': index % 3 == 0 ? 'Late' : 'On Time',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF34C759).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.check_circle_rounded, color: Color(0xFF34C759)),
        ),
        title: Text(mockData['name']!, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${mockData['student_id']}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text('${mockData['time']} • ${mockData['date']}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: mockData['status'] == 'Late'
                ? const Color(0xFFFF9500).withOpacity(0.1)
                : const Color(0xFF34C759).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            mockData['status']!,
            style: TextStyle(
              color: mockData['status'] == 'Late' ? const Color(0xFFFF9500) : const Color(0xFF34C759),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}