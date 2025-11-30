import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'verify_email_screen.dart'; 

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  bool _isLoading = false;
  bool _isCodeSent = false;
  String? _userEmail;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

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
                  _buildForgotPasswordCard(authProvider, size),
                  SizedBox(height: size.height * 0.02),
                  _buildLoginLink(),
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
          _isCodeSent ? 'Check Your Email' : 'Forgot Password',
          style: TextStyle(
            fontSize: size.width * 0.075,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: size.height * 0.008),
        Text(
          _isCodeSent 
            ? 'We sent a 6-digit verification code to your email'
            : 'Enter your Student ID to receive a verification code',
          style: TextStyle(
            fontSize: size.width * 0.04,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForgotPasswordCard(AuthProvider authProvider, Size size) {
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!_isCodeSent) ...[
                _buildFieldLabel('Student ID'),
                SizedBox(height: size.height * 0.012),
                _buildStudentIdField(size),
                
                // Show error message if any
                if (authProvider.errorMessage != null) ...[
                  SizedBox(height: size.height * 0.02),
                  _buildErrorMessage(authProvider.errorMessage!, size),
                ],
                
                SizedBox(height: size.height * 0.03),
                _buildRequestCodeButton(authProvider, size),
              ] else ...[
                _buildSuccessMessage(size),
                SizedBox(height: size.height * 0.03),
                _buildVerifyCodeButton(size),
                SizedBox(height: size.height * 0.02),
                _buildBackToLoginButton(size),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildStudentIdField(Size size) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECF1FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: _studentIdController,
        decoration: const InputDecoration(
          hintText: 'Enter your Student ID',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your Student ID';
          }
          return null;
        },
      ),
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

  Widget _buildRequestCodeButton(AuthProvider authProvider, Size size) {
    final isLoading = _isLoading || authProvider.isLoading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _requestResetCode,
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
                'SEND VERIFICATION CODE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildSuccessMessage(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.mark_email_read_rounded, color: Colors.green, size: 50),
          const SizedBox(height: 10),
          const Text(
            'Verification Code Sent!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 10),
          const Text(
            'A 6-digit verification code has been sent to your email.',
            textAlign: TextAlign.center,
          ),
          if (_userEmail != null) ...[
            const SizedBox(height: 10),
            Text(
              'Email: $_userEmail', 
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

 // In ForgotPasswordScreen's _buildVerifyCodeButton
Widget _buildVerifyCodeButton(Size size) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: () {
        print('🎯 FORGOT PASSWORD - Navigating to VerifyEmailScreen');
        print('   Student ID: ${_studentIdController.text.trim()}');
        print('   Is Password Reset: true');
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyEmailScreen(
              studentId: _studentIdController.text.trim(), // ✅ Make sure this is passed
              email: _userEmail ?? 'user@example.com',
              isPasswordReset: true, // ✅ Make sure this is true
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF60B5FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'ENTER VERIFICATION CODE',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
  Widget _buildBackToLoginButton(Size size) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Color(0xFF60B5FF)),
        ),
        child: const Text(
          'BACK TO LOGIN',
          style: TextStyle(color: Color(0xFF60B5FF), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Wrap(
        children: [
          const Text("Remember your password? "),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Sign In',
              style: TextStyle(color: Color(0xFF667EEA), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestResetCode() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      print(' FORGOT PASSWORD - Requesting reset code for Student ID: ${_studentIdController.text.trim()}');
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.requestPasswordReset(_studentIdController.text.trim());
      
      print(' FORGOT PASSWORD - Response success: $success');
      
      if (success && mounted) {
     
        final responseData = authProvider.currentUser;
        setState(() {
          _isLoading = false;
          _isCodeSent = true;
          // Don't generate fake email - backend should provide the real one
          _userEmail = 'Check your registered email'; // Generic message
        });
        
        print('✅ FORGOT PASSWORD - Code sent successfully');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent to your registered email!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isLoading = false);
        print('❌ FORGOT PASSWORD - Failed to send code: ${authProvider.errorMessage}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send code: ${authProvider.errorMessage ?? "Unknown error"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print(' FORGOT PASSWORD - Exception: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }
}