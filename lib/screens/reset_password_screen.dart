import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String studentId;
  final String email;

  const ResetPasswordScreen({
    Key? key,
    required this.studentId,
    required this.email,
    // ❌ REMOVED: token parameter since we get it from AuthProvider
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Debug the reset token when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('🔑 RESET SCREEN INIT - Student ID: ${widget.studentId}');
      print('🔑 RESET SCREEN INIT - Email: ${widget.email}');
      authProvider.debugResetToken();
    });
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
                
                // Check if reset flow is ready
                if (!authProvider.isResetFlowReady()) 
                  _buildResetFlowError(authProvider, size)
                else
                  _buildResetPasswordCard(authProvider, size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetFlowError(AuthProvider authProvider, Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
          SizedBox(height: size.height * 0.02),
          Text(
            'Reset Token Not Available',
            style: TextStyle(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            'Please go back and verify your reset code again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: Colors.orange[700],
            ),
          ),
          SizedBox(height: size.height * 0.02),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text('Go Back to Verification'),
          ),
          SizedBox(height: size.height * 0.01),
          TextButton(
            onPressed: () {
              authProvider.debugResetToken();
            },
            child: Text(
              'Debug Info',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
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
          child: const Icon(
            Icons.lock_reset_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Text(
          'Set New Password',
          style: TextStyle(
            fontSize: size.width * 0.07,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Text(
          'Create a new password for your account',
          style: TextStyle(
            fontSize: size.width * 0.035,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordCard(AuthProvider authProvider, Size size) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              Container(
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
                      'Student ID: ${widget.studentId}',
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      widget.email,
                      style: TextStyle(
                        fontSize: size.width * 0.033,
                        color: const Color(0xFF667EEA),
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      'Token Status: ${authProvider.resetToken != null ? 'Available (${authProvider.resetToken!.length} chars)' : 'Not available'}',
                      style: TextStyle(
                        fontSize: size.width * 0.030,
                        color: authProvider.resetToken != null ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.03),

              // New Password Field
              _buildPasswordField(
                'New Password',
                _newPasswordController,
                _obscureNewPassword,
                () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                size,
              ),
              SizedBox(height: size.height * 0.02),

              // Confirm Password Field
              _buildPasswordField(
                'Confirm Password',
                _confirmPasswordController,
                _obscureConfirmPassword,
                () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                size,
              ),

              // Error Message
              if (authProvider.errorMessage != null) ...[
                SizedBox(height: size.height * 0.02),
                _buildErrorMessage(authProvider.errorMessage!, size),
              ],

              // Reset Button
              SizedBox(height: size.height * 0.03),
              _buildResetButton(authProvider, size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback toggle,
    Size size,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(fontSize: size.width * 0.037, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: '$label *',
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: size.width * 0.033, fontWeight: FontWeight.w500),
          prefixIcon: Icon(Icons.lock_rounded, color: const Color(0xFF667EEA), size: size.width * 0.045),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey[500], size: size.width * 0.045),
            onPressed: toggle,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: size.height * 0.015),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return '$label is required';
          if (val.length < 6) return 'Password must be at least 6 characters';
          if (label == 'Confirm Password' && val != _newPasswordController.text) {
            return 'Passwords do not match';
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

  Widget _buildResetButton(AuthProvider authProvider, Size size) {
    final isLoading = authProvider.isLoading;

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
          onTap: isLoading ? null : _resetPassword,
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
                        Icons.lock_reset_rounded,
                        color: Colors.white,
                        size: size.width * 0.05,
                      ),
                      SizedBox(width: size.width * 0.025),
                      Text(
                        'RESET PASSWORD',
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

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    print('🔐 RESET PASSWORD SCREEN - Starting password reset');
    print('📤 Student ID from Provider: ${authProvider.resetStudentId}');
    print('🎯 Token from Provider: ${authProvider.resetToken}');
    print('📧 Email from Widget: ${widget.email}');

    final success = await authProvider.resetPassword(
      authProvider.resetStudentId!, // Use the stored student ID
      authProvider.resetToken!,     // Use the stored token
      _newPasswordController.text,
      _confirmPasswordController.text,
    );

    if (success && mounted) {
      print('✅ RESET PASSWORD SCREEN - Password reset successful');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully! You can now login with your new password.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      print('❌ RESET PASSWORD SCREEN - Password reset failed: ${authProvider.errorMessage}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset failed: ${authProvider.errorMessage}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}