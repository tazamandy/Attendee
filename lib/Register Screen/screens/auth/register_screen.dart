import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/validators.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _courseController = TextEditingController();
  final _yearLevelController = TextEditingController();
  final _sectionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _collegeController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final request = RegisterRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        middleName: _middleNameController.text.trim().isEmpty ? null : _middleNameController.text.trim(),
        studentNumber: _studentNumberController.text.trim().isEmpty ? null : _studentNumberController.text.trim(),
        course: _courseController.text.trim().isEmpty ? null : _courseController.text.trim(),
        yearLevel: _yearLevelController.text.trim().isEmpty ? null : _yearLevelController.text.trim(),
        section: _sectionController.text.trim().isEmpty ? null : _sectionController.text.trim(),
        department: _departmentController.text.trim().isEmpty ? null : _departmentController.text.trim(),
        college: _collegeController.text.trim().isEmpty ? null : _collegeController.text.trim(),
        contactNumber: _contactNumberController.text.trim().isEmpty ? null : _contactNumberController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.register(request);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful! Please check your email for verification.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Create Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              
              // Personal Information
              _buildSectionHeader('Personal Information'),
              CustomTextField(
                controller: _firstNameController,
                labelText: 'First Name *',
                validator: (value) => Validators.validateRequired(value, 'First name'),
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _lastNameController,
                labelText: 'Last Name *',
                validator: (value) => Validators.validateRequired(value, 'Last name'),
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _middleNameController,
                labelText: 'Middle Name',
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email *',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _usernameController,
                labelText: 'Username *',
                validator: (value) => Validators.validateRequired(value, 'Username'),
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _contactNumberController,
                labelText: 'Contact Number',
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _addressController,
                labelText: 'Address',
                maxLines: 2,
              ),
              
              // Academic Information
              SizedBox(height: 20),
              _buildSectionHeader('Academic Information'),
              CustomTextField(
                controller: _studentNumberController,
                labelText: 'Student Number',
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _courseController,
                labelText: 'Course',
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _yearLevelController,
                labelText: 'Year Level',
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _sectionController,
                labelText: 'Section',
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _departmentController,
                labelText: 'Department',
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _collegeController,
                labelText: 'College',
              ),
              
              // Password
              SizedBox(height: 20),
              _buildSectionHeader('Security'),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password *',
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm Password *',
                obscureText: true,
                validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
              ),
              
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading 
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Register'),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _studentNumberController.dispose();
    _courseController.dispose();
    _yearLevelController.dispose();
    _sectionController.dispose();
    _departmentController.dispose();
    _collegeController.dispose();
    _contactNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}