import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart';

class MyQRCodeScreen extends StatelessWidget {
  const MyQRCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    // Use the helper getter from AuthProvider instead of direct map access
    final qrData = authProvider.qrCodeData;

    return Scaffold(
      appBar: AppBar(title: const Text('My QR Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: qrData == null || qrData.isEmpty
              ? _buildNoQrCodeUI()
              : _buildQrCodeUI(context, qrData),
        ),
      ),
    );
  }

  Widget _buildNoQrCodeUI() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.qr_code_2, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'No QR Code Available',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        SizedBox(height: 8),
        Text(
          'QR code data is not available for your account',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildQrCodeUI(BuildContext context, String qrData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // User Info Card
        _buildUserInfoCard(context),
        
        const SizedBox(height: 24),
        
        // QR Code Display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 240,
            backgroundColor: Colors.white,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Copy QR Data Button
        ElevatedButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: qrData));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('QR data copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          icon: const Icon(Icons.copy, size: 20),
          label: const Text('Copy QR Data'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // View Payload Button
        OutlinedButton.icon(
          onPressed: () {
            final pretty = _prettyPrint(qrData);
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('QR Code Payload'),
                content: SingleChildScrollView(
                  child: SelectableText(
                    pretty ?? qrData,
                    style: const TextStyle(fontFamily: 'Monospace', fontSize: 12),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: pretty ?? qrData));
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Formatted payload copied')),
                        );
                      }
                    },
                    child: const Text('Copy'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.visibility, size: 20),
          label: const Text('View Payload'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Info text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'This QR code contains your identification data for campus transactions',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.person, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authProvider.userId ?? 'No ID',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    authProvider.course ?? 'No course',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _prettyPrint(String jsonStr) {
    try {
      final obj = json.decode(jsonStr);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(obj);
    } catch (_) {
      return null;
    }
  }
}