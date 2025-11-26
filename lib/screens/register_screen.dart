import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../model/auth_models.dart';
import 'verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key}); // Made constructor const

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;
  String? _selectedYearLevel = '1st Year'; // Default year level

  // Add focus nodes for better form handling
  final Map<String, FocusNode> _focusNodes = {};

  final List<String> yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _controllers['email'] = TextEditingController();
    _controllers['password'] = TextEditingController();
    _controllers['username'] = TextEditingController();
    _controllers['firstName'] = TextEditingController();
    _controllers['lastName'] = TextEditingController();
    _controllers['course'] = TextEditingController();
    _controllers['middleName'] = TextEditingController();
    _controllers['section'] = TextEditingController();
    _controllers['department'] = TextEditingController();
    _controllers['college'] = TextEditingController();
    _controllers['contactNumber'] = TextEditingController();
    _controllers['address'] = TextEditingController();

    // Initialize focus nodes
    _focusNodes['email'] = FocusNode();
    _focusNodes['password'] = FocusNode();
    _focusNodes['username'] = FocusNode();
    _focusNodes['firstName'] = FocusNode();
    _focusNodes['lastName'] = FocusNode();
    _focusNodes['course'] = FocusNode();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    // Dispose all focus nodes
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final request = RegisterRequest(
          email: _controllers['email']!.text.trim(),
          password: _controllers['password']!.text,
          username: _controllers['username']!.text.trim(),
          firstName: _controllers['firstName']!.text.trim(),
          lastName: _controllers['lastName']!.text.trim(),
          course: _controllers['course']!.text.trim(),
          yearLevel: _selectedYearLevel ?? '1st Year',
          middleName: _controllers['middleName']!.text.trim().isEmpty
              ? null
              : _controllers['middleName']!.text.trim(),
          section: _controllers['section']!.text.trim().isEmpty
              ? null
              : _controllers['section']!.text.trim(),
          department: _controllers['department']!.text.trim().isEmpty
              ? null
              : _controllers['department']!.text.trim(),
          college: _controllers['college']!.text.trim().isEmpty
              ? null
              : _controllers['college']!.text.trim(),
          contactNumber: _controllers['contactNumber']!.text.trim().isEmpty
              ? null
              : _controllers['contactNumber']!.text.trim(),
          address: _controllers['address']!.text.trim().isEmpty
              ? null
              : _controllers['address']!.text.trim(),
        );
        bool success = await authProvider.register(request);
        if (success && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VerificationScreen(email: _controllers['email']!.text),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 20),
              const Text(
                'Join Campus Connect',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your account to get started',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // Required Fields Section
              const Text(
                'Required Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),

              _buildTextFormField(
                'Email Address',
                'email',
                Icons.email,
                TextInputType.emailAddress,
                _focusNodes['email']!,
              ),
              _buildTextFormField(
                'Password',
                'password',
                Icons.lock,
                TextInputType.visiblePassword,
                _focusNodes['password']!,
                obscureText: true,
              ),
              _buildTextFormField(
                'Username',
                'username',
                Icons.person,
                TextInputType.text,
                _focusNodes['username']!,
              ),
              _buildTextFormField(
                'First Name',
                'firstName',
                Icons.person,
                TextInputType.text,
                _focusNodes['firstName']!,
              ),
              _buildTextFormField(
                'Last Name',
                'lastName',
                Icons.person,
                TextInputType.text,
                _focusNodes['lastName']!,
              ),
              _buildTextFormField(
                'Course/Program',
                'course',
                Icons.school,
                TextInputType.text,
                _focusNodes['course']!,
              ),
              _buildYearLevelDropdown(),

              const SizedBox(height: 32),

              // Optional Fields Section
              const Text(
                'Additional Information (Optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              _buildTextFormField(
                'Middle Name',
                'middleName',
                Icons.person_outline,
                TextInputType.text,
                FocusNode(),
                required: false,
              ),
              _buildTextFormField(
                'Section',
                'section',
                Icons.group_outlined,
                TextInputType.text,
                FocusNode(),
                required: false,
              ),
              _buildTextFormField(
                'Department',
                'department',
                Icons.business_outlined,
                TextInputType.text,
                FocusNode(),
                required: false,
              ),
              _buildTextFormField(
                'College',
                'college',
                Icons.account_balance_outlined,
                TextInputType.text,
                FocusNode(),
                required: false,
              ),
              _buildTextFormField(
                'Contact Number',
                'contactNumber',
                Icons.phone_outlined,
                TextInputType.phone,
                FocusNode(),
                required: false,
              ),
              _buildTextFormField(
                'Address',
                'address',
                Icons.home_outlined,
                TextInputType.multiline,
                FocusNode(),
                required: false,
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              // Login Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Colors.grey.shade600),
                      children: const [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearLevelDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedYearLevel,
        decoration: InputDecoration(
          labelText: 'Year Level',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.grade),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        items: yearLevels.map((String level) {
          return DropdownMenuItem<String>(value: level, child: Text(level));
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedYearLevel = newValue ?? '1st Year';
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a year level';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    String key,
    IconData icon,
    TextInputType inputType,
    FocusNode focusNode, {
    bool obscureText = false,
    bool required = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _controllers[key],
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: inputType,
        maxLines: maxLines,
        textInputAction: _getTextInputAction(key),
        decoration: InputDecoration(
          labelText: label,
          hintText: required ? null : 'Optional',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(icon),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                if (key == 'email' && !value.contains('@')) {
                  return 'Please enter a valid email address';
                }
                if (key == 'password' && value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              }
            : null,
        onFieldSubmitted: (value) {
          _handleFieldSubmit(key);
        },
      ),
    );
  }

  TextInputAction _getTextInputAction(String key) {
    final fieldOrder = [
      'email',
      'password',
      'username',
      'firstName',
      'lastName',
      'course',
      'yearLevel',
      'middleName',
      'section',
      'department',
      'college',
      'contactNumber',
      'address',
    ];

    final currentIndex = fieldOrder.indexOf(key);
    if (currentIndex < fieldOrder.length - 1) {
      return TextInputAction.next;
    }
    return TextInputAction.done;
  }

  void _handleFieldSubmit(String currentField) {
    final fieldOrder = [
      'email',
      'password',
      'username',
      'firstName',
      'lastName',
      'course',
      'yearLevel',
      'middleName',
      'section',
      'department',
      'college',
      'contactNumber',
      'address',
    ];

    final currentIndex = fieldOrder.indexOf(currentField);
    if (currentIndex < fieldOrder.length - 1) {
      final nextField = fieldOrder[currentIndex + 1];
      final nextFocusNode = _focusNodes[nextField];
      if (nextFocusNode != null) {
        nextFocusNode.requestFocus();
      }
    } else {
      // Last field - submit form
      FocusScope.of(context).unfocus();
      _register();
    }
  }
}
