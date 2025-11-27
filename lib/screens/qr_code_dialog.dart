import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class QRCodeDialog extends StatelessWidget {
  final dynamic user;
  final String studentId;

  const QRCodeDialog({
    Key? key,
    required this.user,
    required this.studentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qrData = _generateQRData(user, studentId);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Pure QR Code Only
          Container(
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 300.0,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),

          // Close Button (floating X)
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
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

  // Static method to show the dialog
  static void show(BuildContext context, {required dynamic user, required String studentId}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QRCodeDialog(
          user: user,
          studentId: studentId,
        );
      },
    );
  }
}