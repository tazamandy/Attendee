import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../provider/auth_provider.dart';

class MyQRCodeScreen extends StatelessWidget {
  const MyQRCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final qrData = user?.qrCodeData;

    return Scaffold(
      appBar: AppBar(title: const Text('My QR Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: qrData == null
              ? const Text('No QR code available for this user.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CustomPaint(
                        size: const Size(240, 240),
                        painter: QrPainter(
                          data: qrData!,
                          version: QrVersions.auto,
                          gapless: true,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: qrData));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('QR data copied')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy QR Payload'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        final pretty = _prettyPrint(qrData);
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('QR Payload'),
                            content: SingleChildScrollView(
                              child: Text(pretty ?? qrData),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('View Payload'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String? _prettyPrint(String? jsonStr) {
    if (jsonStr == null) return null;
    try {
      final obj = json.decode(jsonStr);
      final encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(obj);
    } catch (_) {
      return null;
    }
  }
}

// Using QrPainter from qr_flutter to render QR codes.
