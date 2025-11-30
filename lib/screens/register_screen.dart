import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for all fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _sectionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Dropdown options
  final List<String> _yearLevels = ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year'];

  final List<String> _courses = [
    'BS Information System',
    'BS Computer Science',
    'BS Information Technology',
    'BS Nursing',
    'BS Engineering',
    'BS Business Administration',
    'BS Education',
    'BA Communication',
    'BS Psychology'
  ];

  final List<String> _colleges = [
    'Engineering',
    'Nursing',
    'Computer Studies',
    'Business Admin',
    'Education',
    'Arts & Sciences'
  ];

  String? _selectedYearLevel;
  String? _selectedCourse;
  String? _selectedCollege;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button, title, and logo
                _buildHeader(size),
                SizedBox(height: size.height * 0.03),

                // Registration Form Card
                _buildFormCard(authProvider, size),
                SizedBox(height: size.height * 0.02),

                // Login Link
                _buildLoginLink(),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
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

          // Title
          Text(
            'New Account',
            style: TextStyle(
              fontSize: size.width * 0.06,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),

          // Optimized Logo Loading
          Container(
            width: 60,
            height: 60,
            child: Image.asset(
              'assets/images/logo1.png',
              fit: BoxFit.contain,
              cacheWidth: 80,
              filterQuality: FilterQuality.low,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(AuthProvider authProvider, Size size) {
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
              // Personal Information
              _buildSectionTitle('Personal Info', Icons.person_outline_rounded, size),
              SizedBox(height: size.height * 0.015),

              Row(
                children: [
                  Expanded(child: _buildTextField('First Name', Icons.person_rounded, _firstNameController, size, true)),
                  SizedBox(width: size.width * 0.03),
                  Expanded(child: _buildTextField('Last Name', Icons.person_rounded, _lastNameController, size, true)),
                ],
              ),
              SizedBox(height: size.height * 0.015),
              _buildTextField('Middle Name', Icons.person_rounded, _middleNameController, size, false),
              SizedBox(height: size.height * 0.015),
              _buildTextField('Contact', Icons.phone_rounded, _contactNumberController, size, false, TextInputType.phone),
              SizedBox(height: size.height * 0.015),
              _buildTextField('Address', Icons.home_rounded, _addressController, size, false, TextInputType.text, 2),

              // Academic Information
              SizedBox(height: size.height * 0.025),
              _buildSectionTitle('Academic Info', Icons.school_rounded, size),
              SizedBox(height: size.height * 0.015),

              _buildDropdown('Course', _courses, _selectedCourse, (val) => setState(() => _selectedCourse = val), size, true),
              SizedBox(height: size.height * 0.015),

              Row(
                children: [
                  Expanded(child: _buildDropdown('Year', _yearLevels, _selectedYearLevel, (val) => setState(() => _selectedYearLevel = val), size, true)),
                  SizedBox(width: size.width * 0.03),
                  Expanded(child: _buildDropdown('College', _colleges, _selectedCollege, (val) => setState(() => _selectedCollege = val), size, true)),
                ],
              ),
              SizedBox(height: size.height * 0.015),

              Row(
                children: [
                  Expanded(child: _buildTextField('Department', Icons.business_rounded, _departmentController, size, false)),
                  SizedBox(width: size.width * 0.03),
                  Expanded(child: _buildTextField('Section', Icons.group_rounded, _sectionController, size, false)),
                ],
              ),

              // Account Information
              SizedBox(height: size.height * 0.025),
              _buildSectionTitle('Account Info', Icons.lock_outline_rounded, size),
              SizedBox(height: size.height * 0.015),

              _buildTextField('Email', Icons.email_rounded, _emailController, size, true, TextInputType.emailAddress),
              SizedBox(height: size.height * 0.015),
              _buildPasswordField('Password', _passwordController, _obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword), size),
              SizedBox(height: size.height * 0.015),
              _buildPasswordField('Confirm Password', _confirmPasswordController, _obscureConfirmPassword, () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword), size),

              // Error Message
              if (authProvider.errorMessage != null) ...[
                SizedBox(height: size.height * 0.02),
                _buildErrorMessage(authProvider.errorMessage!, size),
              ],

              // Register Button
              SizedBox(height: size.height * 0.025),
              _buildRegisterButton(authProvider, size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Size size) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(size.width * 0.02),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF667EEA), size: size.width * 0.045),
        ),
        SizedBox(width: size.width * 0.025),
        Text(
          title,
          style: TextStyle(
            fontSize: size.width * 0.042,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, Size size, bool required, [TextInputType type = TextInputType.text, int lines = 1]) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: lines,
        style: TextStyle(fontSize: size.width * 0.037, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: size.width * 0.033, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: const Color(0xFF667EEA), size: size.width * 0.045),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: size.height * 0.015),
        ),
        validator: required ? (val) => (val == null || val.isEmpty) ? '$label required' : null : null,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged, Size size, bool required) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: size.width * 0.033, fontWeight: FontWeight.w500),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: size.height * 0.012),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: TextStyle(fontSize: size.width * 0.035), overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
        validator: required ? (val) => (val == null || val.isEmpty) ? 'Required' : null : null,
        icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.grey[500]),
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscure, VoidCallback toggle, Size size) {
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
          if (val == null || val.isEmpty) return '$label required';
          if (label == 'Password' && val.length < 6) return 'Min 6 characters';
          if (label == 'Confirm Password' && val != _passwordController.text) return 'Passwords do not match';
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
          Expanded(child: Text(message, style: TextStyle(color: Colors.red[700], fontSize: size.width * 0.033, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(AuthProvider authProvider, Size size) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF60B5FF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF60B5FF).withOpacity(0.4),
            blurRadius: 20, 
            offset: const Offset(0, 8)
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: authProvider.isLoading ? null : () async {
            if (_formKey.currentState!.validate()) await _registerUser(authProvider);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
            child: authProvider.isLoading
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
                        Icons.person_add_alt_1_rounded, 
                        color: Colors.white,
                        size: size.width * 0.05
                      ),
                      SizedBox(width: size.width * 0.025),
                      Text(
                        'CREATE ACCOUNT', 
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.038, 
                          fontWeight: FontWeight.w700, 
                          letterSpacing: 0.8
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Wrap(
        children: [
          Text('Already have an account? ', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text('Sign In', style: TextStyle(color: Color(0xFF667EEA), fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _registerUser(AuthProvider authProvider) async {
    try {
      print('🚀 STARTING REGISTRATION PROCESS');
      
      // Clear previous errors
      authProvider.clearError();

      // Validate dropdowns
      if (_selectedCourse == null || _selectedYearLevel == null || _selectedCollege == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill all required academic information'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final data = {
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
        "username": _emailController.text.trim().split('@').first,
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "middle_name": _middleNameController.text.trim().isEmpty ? null : _middleNameController.text.trim(),
        "course": _selectedCourse!,
        "year_level": _selectedYearLevel!,
        "section": _sectionController.text.trim().isEmpty ? null : _sectionController.text.trim(),
        "department": _departmentController.text.trim().isEmpty ? null : _departmentController.text.trim(),
        "college": _selectedCollege!,
        "contact_number": _contactNumberController.text.trim().isEmpty ? null : _contactNumberController.text.trim(),
        "address": _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        "student_id": "",
      };

      print('📦 REGISTRATION DATA:');
      print('   Email: ${data['email']}');
      print('   First Name: ${data['first_name']}');
      print('   Last Name: ${data['last_name']}');
      print('   Course: ${data['course']}');
      print('   Year Level: ${data['year_level']}');
      print('   College: ${data['college']}');

      final result = await authProvider.register(data);
      
      print('🎯 REGISTRATION RESULT: $result');
      
      if (!mounted) return;

      // ✅ BAGONG IMPROVED LOGIC - Handle Map response
      if (result['success'] == true) {
        if (result['requiresVerification'] == true) {
          print('⏳ REGISTRATION SUCCESSFUL - VERIFICATION REQUIRED');
          _navigateToVerification(
            'Registration successful! Please check your email for verification code.',
            _emailController.text.trim(),
            result['studentId'] ?? ''
          );
        } else {
          print('✅ REGISTRATION COMPLETE - DIRECT LOGIN SUCCESSFUL');
          _showSuccessMessage('Registration completed successfully!');
          // Navigate to login or dashboard
          Future.delayed(Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } else {
        print('❌ REGISTRATION FAILED: ${result['message']}');
        _showErrorMessage(result['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('💥 REGISTRATION EXCEPTION: $e');
      if (mounted) {
        _showErrorMessage('Registration error: $e');
      }
    }
  }

  void _navigateToVerification(String message, String email, String studentId) {
    // TEMPORARY: Navigate back to login for now
    // You need to create the actual verification screen first
    Navigator.pop(context);
    
    _showSuccessMessage('$message - Please check your email and verify your account.');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.white), 
          SizedBox(width: 12), 
          Expanded(child: Text(message))
        ]),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(Icons.error_rounded, color: Colors.white), 
          SizedBox(width: 12), 
          Expanded(child: Text(message))
        ]),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _sectionController.dispose();
    _departmentController.dispose();
    _contactNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}