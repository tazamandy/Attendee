import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final String? studentId;
  final bool isPasswordReset;
  
  const VerifyEmailScreen({
    Key? key, 
    required this.email,
    this.studentId,
    this.isPasswordReset = false,
  }) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _codeControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(size),
                SizedBox(height: size.height * 0.03),
                _buildHeaderContent(size),
                SizedBox(height: size.height * 0.03),
                _buildEmailInfo(size),
                SizedBox(height: size.height * 0.04),
                _buildCodeInputFields(size),
                
                // Error Message from AuthProvider
                if (authProvider.errorMessage != null) ...[
                  SizedBox(height: size.height * 0.02),
                  _buildErrorMessage(authProvider.errorMessage!, size),
                ],
                
                SizedBox(height: size.height * 0.04),
                _buildVerifyButton(authProvider, size),
                SizedBox(height: size.height * 0.02),
                _buildResendCode(size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(Size size) {
    return Container(
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
        icon: Icon(Icons.arrow_back_rounded, color: const Color(0xFF667EEA), size: size.width * 0.06),
        padding: EdgeInsets.all(size.width * 0.02),
      ),
    );
  }

  Widget _buildHeaderContent(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(size.width * 0.04),
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
            size: size.width * 0.08,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Text(
          widget.isPasswordReset ? 'Reset Your Password' : 'Verify Your Email',
          style: TextStyle(
            fontSize: size.width * 0.07,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Text(
          widget.isPasswordReset 
            ? 'Enter the 6-digit verification code to reset your password'
            : 'We sent a 6-digit verification code to your email address.',
          style: TextStyle(
            fontSize: size.width * 0.035,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInfo(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF667EEA).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            widget.isPasswordReset && widget.studentId != null 
              ? 'Student ID: ${widget.studentId}'
              : 'Verification code sent to:',
            style: TextStyle(
              fontSize: size.width * 0.033,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: size.height * 0.005),
          Text(
            widget.email,
            style: TextStyle(
              fontSize: size.width * 0.038,
              color: const Color(0xFF667EEA),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInputFields(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter 6-digit Code *',
          style: TextStyle(
            fontSize: size.width * 0.035,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: size.width * 0.12,
              child: TextField(
                controller: _codeControllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF667EEA),
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                ),
                onChanged: (value) {
                  if (value.length == 1 && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                  if (_isAllFieldsFilled() && index == 5) {
                    _verifyCode();
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

  Widget _buildVerifyButton(AuthProvider authProvider, Size size) {
    final isLoading = _isLoading || authProvider.isLoading;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF60B5FF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF60B5FF).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isLoading ? null : _verifyCode,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: size.width * 0.05,
                      height: size.width * 0.05,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isPasswordReset ? Icons.lock_reset_rounded : Icons.verified_rounded,
                        color: Colors.white,
                        size: size.width * 0.05,
                      ),
                      SizedBox(width: size.width * 0.025),
                      Text(
                        widget.isPasswordReset ? 'RESET PASSWORD' : 'VERIFY EMAIL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.038,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendCode(Size size) {
    return Center(
      child: Column(
        children: [
          Text(
            "Didn't receive the code?",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: size.width * 0.033,
            ),
          ),
          SizedBox(height: size.height * 0.005),
          _isResending
              ? SizedBox(
                  width: size.width * 0.05,
                  height: size.width * 0.05,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                  ),
                )
              : TextButton(
                  onPressed: _isResending ? null : _resendCode,
                  child: Text(
                    'RESEND CODE',
                    style: TextStyle(
                      color: const Color(0xFF667EEA),
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  bool _isAllFieldsFilled() {
    return _codeControllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getVerificationCode() {
    return _codeControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyCode() async {
    if (!_isAllFieldsFilled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit code'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final code = _getVerificationCode();
      print(' VERIFY SCREEN - Verifying code: $code for email: ${widget.email}');

     
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.verifyEmail(widget.email, code);

      if (success && mounted) {
        print(' VERIFY SCREEN - Email verification successful!');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isPasswordReset 
              ? 'Password reset successful!' 
              : 'Email verified successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Clear all fields after successful verification
        _clearAllFields();
        
        // Navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print('❌ VERIFY SCREEN - Verification failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification failed: ${authProvider.errorMessage ?? 'Invalid code'}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Refocus on first field for retry
          _focusNodes[0].requestFocus();
        }
      }
    } catch (e) {
      print('💥 VERIFY SCREEN - Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      print('🔄 VERIFY SCREEN - Resending code to: ${widget.email}');
      
      // TODO: Implement actual resend code API call
      // For now, just simulate
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New verification code sent to your email!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Clear existing code for new entry
        _clearAllFields();
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend code: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _clearAllFields() {
    for (var controller in _codeControllers) {
      controller.clear();
    }
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}