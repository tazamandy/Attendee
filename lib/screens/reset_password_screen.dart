import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String studentId;
  final String email;
  final String? token;
  
  const ResetPasswordScreen({
    Key? key,
    required this.studentId,
    required this.email,
    this.token,
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(size),
                  SizedBox(height: size.height * 0.04),
                  _buildResetPasswordCard(size),
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
              constraints: const BoxConstraints(),
            ),
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Text(
          'Reset Password',
          style: TextStyle(
            fontSize: size.width * 0.075,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: size.height * 0.008),
        Text(
          'Create your new password',
          style: TextStyle(
            fontSize: size.width * 0.04,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResetPasswordCard(Size size) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudentInfo(size),
              SizedBox(height: size.height * 0.025),
              _buildFieldLabel('New Password'),
              SizedBox(height: size.height * 0.012),
              _buildNewPasswordField(size),
              SizedBox(height: size.height * 0.025),
              _buildFieldLabel('Confirm Password'),
              SizedBox(height: size.height * 0.012),
              _buildConfirmPasswordField(size),
              SizedBox(height: size.height * 0.03),
              _buildResetButton(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfo(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC6F6D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: TextStyle(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.w700,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: size.height * 0.01),
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
            'Email: ${widget.email}',
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: Colors.grey[600],
            ),
          ),
          if (widget.token != null && widget.token!.isNotEmpty)
            SizedBox(height: size.height * 0.005),
          if (widget.token != null && widget.token!.isNotEmpty)
            Text(
              'Token: •••${widget.token!.substring(widget.token!.length - 8)}',
              style: TextStyle(
                fontSize: size.width * 0.03,
                color: Colors.grey[500],
                fontFamily: 'Monospace',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildNewPasswordField(Size size) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECF1FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: _newPasswordController,
        obscureText: _obscureNewPassword,
        style: TextStyle(
          fontSize: size.width * 0.04,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Enter new password',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.lock_rounded,
            color: const Color(0xFF667EEA),
            size: size.width * 0.055,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureNewPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: Colors.grey[500],
              size: size.width * 0.055,
            ),
            onPressed: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.02,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter new password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildConfirmPasswordField(Size size) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECF1FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        style: TextStyle(
          fontSize: size.width * 0.04,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Confirm new password',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.lock_reset_rounded,
            color: const Color(0xFF667EEA),
            size: size.width * 0.055,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: Colors.grey[500],
              size: size.width * 0.055,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.02,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please confirm your password';
          }
          if (value != _newPasswordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildResetButton(Size size) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF60B5FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF60B5FF).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isLoading ? null : _resetPassword,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
            child: _isLoading
                ? Center(
                    child: SizedBox(
                      width: size.width * 0.06,
                      height: size.width * 0.06,
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
                        Icons.vpn_key_rounded,
                        color: Colors.white,
                        size: size.width * 0.055,
                      ),
                      SizedBox(width: size.width * 0.03),
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
    if (_formKey.currentState!.validate()) {
      if (widget.token == null || widget.token!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset token is missing. Please request a new reset link.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        final success = await authProvider.resetPassword(
          widget.studentId,
          widget.token!,
          _newPasswordController.text,
          _confirmPasswordController.text,
        );

        if (success && mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Password reset successfully!'),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reset password: ${authProvider.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password: $e'),
            backgroundColor: Colors.red,
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