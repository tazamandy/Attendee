import 'dart:async'; // For TimeoutException
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VerifyUserScreen extends StatefulWidget {
  final String tempUserId; // galing registration
  const VerifyUserScreen({Key? key, required this.tempUserId}) : super(key: key);

  @override
  _VerifyUserScreenState createState() => _VerifyUserScreenState();
}

class _VerifyUserScreenState extends State<VerifyUserScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitVerification() async {
    final code = _codeController.text.trim();
    final studentId = _studentIdController.text.trim();

    if (code.isEmpty || studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter code and Student ID')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final httpResponse = await http
          .post(
            Uri.parse('https://your-backend.com/verify-user'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'temp_user_id': widget.tempUserId,
              'code': code,
              'student_id': studentId,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (httpResponse.statusCode == 200) {
        final data = jsonDecode(httpResponse.body);
        if (data['success'] == true) {
          // Verification success → navigate to dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${httpResponse.statusCode}')),
        );
      }
    } on TimeoutException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network timeout. Try again.')),
      );
    } on http.ClientException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Client error: $e')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the verification code sent to your email and your Student ID.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitVerification,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify & Complete Registration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
