import 'package:flutter/material.dart';

class AttendanceLogScreen extends StatefulWidget {
  const AttendanceLogScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceLogScreen> createState() => _AttendanceLogsScreenState();
}

class _AttendanceLogsScreenState extends State<AttendanceLogScreen> {
  List<Map<String, dynamic>> attendanceLogs = [
    {
      'id': '001',
      'studentName': 'Juan Dela Cruz',
      'studentId': '2023-001',
      'event': 'School Assembly',
      'timeIn': '2024-01-20 08:15:00',
      'timeOut': '2024-01-20 12:00:00',
      'status': 'Present',
      'scannedBy': 'Admin 1',
    },
    {
      'id': '002',
      'studentName': 'Maria Santos',
      'studentId': '2023-002',
      'event': 'Math Class',
      'timeIn': '2024-01-20 09:00:00',
      'timeOut': '2024-01-20 10:30:00',
      'status': 'Present',
      'scannedBy': 'Admin 2',
    },
    {
      'id': '003',
      'studentName': 'Pedro Reyes',
      'studentId': '2023-003',
      'event': 'School Assembly',
      'timeIn': '2024-01-20 08:45:00',
      'timeOut': '2024-01-20 12:00:00',
      'status': 'Late',
      'scannedBy': 'Admin 1',
    },
    {
      'id': '004',
      'studentName': 'Ana Lim',
      'studentId': '2023-004',
      'event': 'Science Lab',
      'timeIn': '2024-01-20 13:30:00',
      'timeOut': '2024-01-20 15:00:00',
      'status': 'Present',
      'scannedBy': 'Admin 3',
    },
    {
      'id': '005',
      'studentName': 'Luis Tan',
      'studentId': '2023-005',
      'event': 'School Assembly',
      'timeIn': null,
      'timeOut': null,
      'status': 'Absent',
      'scannedBy': 'System',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Attendance Logs',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard('Total', '1,234', Icons.people_rounded,
                      const Color(0xFF007AFF)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('Present', '1,100',
                      Icons.check_circle_rounded, const Color(0xFF34C759)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                      'Absent', '89', Icons.cancel_rounded, const Color(0xFFFF3B30)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('Late', '45',
                      Icons.watch_later_rounded, const Color(0xFFFF9500)),
                ),
              ],
            ),
          ),
          // Filter and Search
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search logs...',
                        border: InputBorder.none,
                        icon: const Icon(Icons.search_rounded, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.date_range_rounded, color: Colors.grey),
                    onPressed: () => _showDatePicker(),
                  ),
                ),
              ],
            ),
          ),
          // Logs Table
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: attendanceLogs.length,
              itemBuilder: (context, index) {
                final log = attendanceLogs[index];
                return _buildLogCard(log);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D1D1F)),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(log['status']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              _getStatusIcon(log['status']),
              color: _getStatusColor(log['status']),
              size: 20,
            ),
          ),
        ),
        title: Text(
          log['studentName'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          log['studentId'],
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(log['status']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            log['status'],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(log['status']),
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildDetailRow('Event', log['event']),
                const SizedBox(height: 8),
                _buildDetailRow('Time In', log['timeIn'] ?? 'Not recorded'),
                const SizedBox(height: 8),
                _buildDetailRow('Time Out', log['timeOut'] ?? 'Not recorded'),
                const SizedBox(height: 8),
                _buildDetailRow('Scanned By', log['scannedBy']),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // View details
                        },
                        icon: const Icon(Icons.visibility_rounded, size: 16),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF007AFF)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Generate report
                        },
                        icon: const Icon(Icons.print_rounded, size: 16),
                        label: const Text('Print'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34C759),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1D1D1F),
                fontSize: 13),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return const Color(0xFF34C759);
      case 'Absent':
        return const Color(0xFFFF3B30);
      case 'Late':
        return const Color(0xFFFF9500);
      default:
        return const Color(0xFF007AFF);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Present':
        return Icons.check_circle_rounded;
      case 'Absent':
        return Icons.cancel_rounded;
      case 'Late':
        return Icons.watch_later_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Filter Logs',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('Present', const Color(0xFF34C759)),
              _buildFilterOption('Absent', const Color(0xFFFF3B30)),
              _buildFilterOption('Late', const Color(0xFFFF9500)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filter applied')),
                );
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String label, Color color) {
    return CheckboxListTile(
      title: Text(label),
      secondary: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      value: true,
      onChanged: (value) {},
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    ).then((date) {
      if (date != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected date: ${date.toLocal()}')),
        );
      }
    });
  }
}