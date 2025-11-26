import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  final String studentId;
  final bool isPasswordReset;
  
  const VerifyCodeScreen({
    Key? key, 
    required this.email,
    required this.studentId,
    this.isPasswordReset = false,
  }) : super(key: key);

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxWidth: 500,
                minHeight: size.height - MediaQuery.of(context).padding.top,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF667EEA)),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      widget.isPasswordReset ? Icons.vpn_key_rounded : Icons.verified_user_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    widget.isPasswordReset ? 'Verify Password Reset' : 'Verify Your Email',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  Text(
                    widget.isPasswordReset 
                      ? 'Enter the 6-digit code to reset your password'
                      : 'We sent a 6-digit verification code to your email',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Email/Student Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF667EEA).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.isPasswordReset ? 'Student ID' : 'Email',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.isPasswordReset ? widget.studentId : widget.email,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Code Input
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Enter 6-digit Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF60B5FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.isPasswordReset ? 'VERIFY & RESET PASSWORD' : 'VERIFY CODE',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Resend Code
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('New code sent!')),
                      );
                    },
                    child: const Text(
                      'Resend Code',
                      style: TextStyle(color: Color(0xFF667EEA)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (widget.isPasswordReset) {
      // For password reset - simulate success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code verified! Redirecting to password reset...')),
      );
      // Navigate to reset password screen
      Navigator.pushReplacementNamed(
        context, 
        '/reset-password',
        arguments: {
          'studentId': widget.studentId,
          'email': widget.email,
        },
      );
    } else {
      // For email verification - simulate success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified successfully!')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
    
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}