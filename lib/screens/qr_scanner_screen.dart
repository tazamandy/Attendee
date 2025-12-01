// lib/screens/superadmin/qr_scanner_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController(
    torchEnabled: false,
    facing: CameraFacing.back,
  );
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.off ? Icons.flash_off : Icons.flash_on,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacing,
              builder: (context, state, child) {
                // Show different icon based on current camera facing
                if (state == CameraFacing.front) {
                  return const Icon(Icons.camera_rear_rounded, color: Colors.white);
                } else {
                  return const Icon(Icons.camera_front_rounded, color: Colors.white);
                }
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!_isProcessing) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  _handleScannedCode(barcode.rawValue ?? '');
                }
              }
            },
          ),
          _buildScannerOverlay(),
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Corner indicators
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFF34C759), width: 5),
                    left: BorderSide(color: Color(0xFF34C759), width: 5),
                  ),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFF34C759), width: 5),
                    right: BorderSide(color: Color(0xFF34C759), width: 5),
                  ),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF34C759), width: 5),
                    left: BorderSide(color: Color(0xFF34C759), width: 5),
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF34C759), width: 5),
                    right: BorderSide(color: Color(0xFF34C759), width: 5),
                  ),
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 40),
            SizedBox(height: 12),
            Text(
              'Align QR code within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Scanner will automatically detect the code',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleScannedCode(String code) async {
    if (code.isEmpty) return;

    setState(() => _isProcessing = true);

    // Stop the scanner temporarily
    await cameraController.stop();

    try {
      // Try to parse the QR code data
      final userData = json.decode(code) as Map<String, dynamic>;

      if (!mounted) return;

      // Show user details dialog
      await _showUserDetailsDialog(userData);
    } catch (e) {
      if (!mounted) return;

      // If parsing fails, show raw data
      await _showErrorDialog('Invalid QR Code', 'Could not parse QR code data:\n$code\n\nError: $e');
    } finally {
      setState(() => _isProcessing = false);
      
      // Resume scanning after dialog is closed
      if (mounted && !_isProcessing) {
        await cameraController.start();
      }
    }
  }

  Future<void> _showUserDetailsDialog(Map<String, dynamic> userData) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xFF34C759), size: 50),
                ),
                const SizedBox(height: 20),
                const Text(
                  'QR Code Scanned',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F)),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Student ID', userData['student_id']?.toString() ?? 'N/A'),
                      const Divider(height: 20),
                      _buildDetailRow('Name', '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim()),
                      const Divider(height: 20),
                      _buildDetailRow('Email', userData['email']?.toString() ?? 'N/A'),
                      const Divider(height: 20),
                      _buildDetailRow('Course', userData['course']?.toString() ?? 'N/A'),
                      const Divider(height: 20),
                      _buildDetailRow('Year Level', userData['year_level']?.toString() ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF007AFF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Close', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _recordAttendance(userData);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34C759),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Mark Attendance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 14),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F), fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Future<void> _showErrorDialog(String title, String message) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.error_rounded, color: Color(0xFFFF3B30)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _recordAttendance(Map<String, dynamic> userData) {
    // TODO: Implement actual event fetching logic
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Sample events data - replace with actual API call
        final List<Map<String, dynamic>> events = [
          {
            'id': '1',
            'name': 'Tech Conference 2024',
            'date': 'Oct 15, 2024',
            'location': 'Main Auditorium',
          },
          {
            'id': '2',
            'name': 'Leadership Summit',
            'date': 'Nov 22, 2024',
            'location': 'Conference Hall',
          },
          {
            'id': '3',
            'name': 'Career Fair',
            'date': 'Dec 5, 2024',
            'location': 'Student Center',
          },
        ];

        return AlertDialog(
          title: const Text('Select Event', style: TextStyle(fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(event['name']),
                    subtitle: Text('${event['date']} • ${event['location']}'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.of(context).pop();
                      // Record attendance for selected event
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Attendance recorded for ${userData['first_name']} ${userData['last_name']} at ${event['name']}',
                          ),
                          backgroundColor: const Color(0xFF34C759),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      
                      // TODO: Implement actual attendance recording API call
                      // _recordAttendanceToAPI(userData['student_id'], event['id']);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFFFF3B30))),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Ensure scanner starts when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await cameraController.start();
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}