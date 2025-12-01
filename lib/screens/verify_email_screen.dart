// screens/verify_email_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as auth_provider; // FIXED: Added alias

class VerifyEmailScreen extends StatefulWidget {
  final String studentId;
  final String email;
  final bool isPasswordReset;

  const VerifyEmailScreen({
    Key? key,
    required this.studentId,
    required this.email,
    this.isPasswordReset = false,
  }) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Clear any previous errors when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<auth_provider.AuthProvider>(context, listen: false);
      authProvider.clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<auth_provider.AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 500,
                minHeight: size.height - MediaQuery.of(context).padding.top,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.03,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(size),
                  SizedBox(height: size.height * 0.04),
                  _buildVerificationCard(authProvider, size),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF667EEA)),
            ),
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Text(
          widget.isPasswordReset ? 'Verify Your Identity' : 'Verify Your Email',
          style: TextStyle(
            fontSize: size.width * 0.075,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: size.height * 0.008),
        Text(
          widget.isPasswordReset 
              ? 'Enter the 6-digit code to reset your password'
              : 'Enter the 6-digit code sent to your email',
          style: TextStyle(
            fontSize: size.width * 0.04,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: size.height * 0.008),
        Text(
          widget.email,
          style: TextStyle(
            fontSize: size.width * 0.035,
            color: const Color(0xFF667EEA),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationCard(auth_provider.AuthProvider authProvider, Size size) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.07),
        child: Column(
          children: [
            _buildCodeFields(size),
            SizedBox(height: size.height * 0.03),
            
            if (authProvider.errorMessage != null) ...[
              _buildErrorMessage(authProvider.errorMessage!, size),
              SizedBox(height: size.height * 0.02),
            ],
            
            _buildVerifyButton(authProvider, size),
            SizedBox(height: size.height * 0.02),
            _buildResendCode(authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeFields(Size size) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Verification Code',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: size.width * 0.12,
              height: size.width * 0.14,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF667EEA)),
                  ),
                ),
                onChanged: (value) {
                  if (value.length == 1 && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.035),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red[600], size: size.width * 0.045),
          SizedBox(width: size.width * 0.025),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: size.width * 0.033,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton(auth_provider.AuthProvider authProvider, Size size) {
    final isLoading = _isLoading || authProvider.isLoading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _verifyCode(authProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF60B5FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'VERIFY CODE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildResendCode(auth_provider.AuthProvider authProvider) {
    return Center(
      child: Wrap(
        children: [
          const Text("Didn't receive the code? "),
          GestureDetector(
            onTap: () => _resendCode(authProvider),
            child: const Text(
              'Resend',
              style: TextStyle(color: Color(0xFF667EEA), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyCode(auth_provider.AuthProvider authProvider) async {
    final code = _controllers.map((controller) => controller.text).join();
    
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔐 VERIFY EMAIL - Verifying code for Student ID: ${widget.studentId}');
      print('   Code: $code');
      print('   Is Password Reset: ${widget.isPasswordReset}');

      // FIXED: Use the correct method name based on whether it's password reset or email verification
      final success = widget.isPasswordReset
          ? await authProvider.verifyResetCode(widget.studentId, code)
          : await authProvider.verifyRegistrationEmail(widget.email, code);

      if (success && mounted) {
        setState(() => _isLoading = false);
        print('✅ VERIFY EMAIL - Code verified successfully');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate based on whether it's password reset or email verification
        if (widget.isPasswordReset) {
          // Navigate to reset password screen
          Navigator.pushReplacementNamed(context, '/reset-password');
        } else {
          // Navigate to complete profile or main app
          Navigator.pushReplacementNamed(context, '/student-dashboard');
        }
      } else {
        setState(() => _isLoading = false);
        print('❌ VERIFY EMAIL - Code verification failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ VERIFY EMAIL - Exception: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resendCode(auth_provider.AuthProvider authProvider) async {
    try {
      final success = widget.isPasswordReset
          ? await authProvider.requestPasswordReset(widget.studentId)
          : await authProvider.requestEmailVerification(widget.email);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code resent!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear all code fields
        for (var controller in _controllers) {
          controller.clear();
        }
        // Focus on first field
        _focusNodes[0].requestFocus();
        
        // Clear any errors
        authProvider.clearError();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}