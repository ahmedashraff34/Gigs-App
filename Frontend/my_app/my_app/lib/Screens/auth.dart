import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../services/auth_service.dart';
import '../services/token_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../Widgets/user_image_picker.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _authService = AuthService();
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPassword = '';
  var _enteredConfirmPassword = '';
  var _enteredFirstName = '';
  var _enteredLastName = '';
  var _enteredGovernmentId = '';
  var _enteredPhoneNumber = '';
  File? _selectedImage;
  var _selectedRoles = <String>[]; // List to store selected roles
  var _isLoading = false;
  String? _tempPassword; // Add this line to store password temporarily
  String? _authToken; // Store the authentication token
  int _signupStep = 0;
  final _signupSteps = 3;
  File? _signupImage;
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 150,
      );

      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleRole(String role) {
    setState(() {
      if (_selectedRoles.contains(role)) {
        _selectedRoles.remove(role);
      } else {
        _selectedRoles.add(role);
      }
    });
  }

  void _nextSignupStep() {
    if (_signupStep < _signupSteps - 1) {
      setState(() => _signupStep++);
    }
  }
  void _prevSignupStep() {
    if (_signupStep > 0) {
      setState(() => _signupStep--);
    }
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _logoAnimation,
      child: Padding(
        padding: const EdgeInsets.only(top: 40, bottom: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(Icons.flash_on, color: Theme.of(context).colorScheme.primary, size: 40),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gigs',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF11366A),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Card(
        key: const ValueKey('login'),
        margin: const EdgeInsets.all(20),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const ValueKey('username'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  decoration: InputDecoration(labelText: 'Username', fillColor: Theme.of(context).colorScheme.secondary),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your username.' : null,
                  onSaved: (value) => _enteredUsername = value!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('password'),
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password', fillColor: Theme.of(context).colorScheme.secondary),
                  validator: (value) {
                    _tempPassword = value;
                    if (value == null || value.trim().length < 6) {
                      return 'Password must be at least 6 characters long.';
                    }
                    return null;
                  },
                  onSaved: (value) => _enteredPassword = value!.trim(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRoleSelector('runner', Icons.directions_run, 'Runner'),
                    const SizedBox(width: 20),
                    _buildRoleSelector('task_poster', Icons.assignment, 'Task Poster'),
                  ],
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Login', style: TextStyle(fontSize: 18)),
                      ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = false;
                      _signupStep = 0;
                    });
                  },
                  child: Text('Create an account', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector(String role, IconData icon, String label) {
    final selected = _selectedRoles.contains(role);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
      decoration: BoxDecoration(
        color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: selected
            ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))]
            : [],
      ),
      child: InkWell(
        onTap: () => _toggleRole(role),
        child: Column(
          children: [
            Icon(icon, color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupStepper() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Card(
        key: ValueKey(_signupStep),
        margin: const EdgeInsets.all(20),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stepper(
                  type: StepperType.vertical,
                  currentStep: _signupStep,
                  onStepContinue: _signupStep < _signupSteps - 1 ? _nextSignupStep : _submit,
                  onStepCancel: _signupStep > 0 ? _prevSignupStep : null,
                  controlsBuilder: (context, details) {
                    return Row(
                      children: <Widget>[
                        if (_signupStep < _signupSteps - 1)
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Next'),
                          ),
                        if (_signupStep == _signupSteps - 1)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Signup'),
                          ),
                        if (_signupStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                      ],
                    );
                  },
                  steps: [
                    Step(
                      title: const Text('Profile Image'),
                      isActive: _signupStep >= 0,
                      state: _signupStep > 0 ? StepState.complete : StepState.indexed,
                      content: UserImagePicker(
                        onPickImage: (img) => setState(() => _signupImage = img),
                      ),
                    ),
                    Step(
                      title: const Text('Personal Info'),
                      isActive: _signupStep >= 1,
                      state: _signupStep > 1 ? StepState.complete : StepState.indexed,
                      content: Column(
                        children: [
                          TextFormField(
                            key: const ValueKey('firstname'),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(labelText: 'First Name', fillColor: Theme.of(context).colorScheme.secondary),
                            validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your first name.' : null,
                            onSaved: (value) => _enteredFirstName = value!,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const ValueKey('lastname'),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(labelText: 'Last Name', fillColor: Theme.of(context).colorScheme.secondary),
                            validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your last name.' : null,
                            onSaved: (value) => _enteredLastName = value!,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const ValueKey('phonenumber'),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(labelText: 'Phone Number', fillColor: Theme.of(context).colorScheme.secondary),
                            validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your phone number.' : null,
                            onSaved: (value) => _enteredPhoneNumber = value!,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const ValueKey('governmentid'),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(labelText: 'Government ID', fillColor: Theme.of(context).colorScheme.secondary),
                            validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your government ID.' : null,
                            onSaved: (value) => _enteredGovernmentId = value!,
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Account Info'),
                      isActive: _signupStep >= 2,
                      state: StepState.indexed,
                      content: Column(
                        children: [
                          TextFormField(
                            key: const ValueKey('email_signup'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            decoration: InputDecoration(labelText: 'Email Address', fillColor: Theme.of(context).colorScheme.secondary),
                            validator: (value) => value == null || !value.contains('@') ? 'Please enter a valid email address.' : null,
                            onSaved: (value) => _enteredEmail = value!,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const ValueKey('username_signup'),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            decoration: InputDecoration(labelText: 'Username', fillColor: Theme.of(context).colorScheme.secondary),
                            validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your username.' : null,
                            onSaved: (value) => _enteredUsername = value!.trim(),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const ValueKey('password_signup'),
                            obscureText: true,
                            decoration: InputDecoration(labelText: 'Password', fillColor: Theme.of(context).colorScheme.secondary),
                            validator: (value) {
                              _tempPassword = value;
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) => _enteredPassword = value!.trim(),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const ValueKey('confirmpassword_signup'),
                            obscureText: true,
                            decoration: InputDecoration(labelText: 'Confirm Password', fillColor: Theme.of(context).colorScheme.secondary),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please confirm your password.';
                              }
                              if (value != _tempPassword) {
                                return 'Passwords do not match.';
                              }
                              return null;
                            },
                            onSaved: (value) => _enteredConfirmPassword = value!,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = true;
                      _signupStep = 0;
                    });
                  },
                  child: Text('I already have an account', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // For login, we need to select a role
        if (_selectedRoles.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a role to continue.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Try Spring backend login first
        final loginResult = await _authService.loginWithBackend(
          username: _enteredUsername,
          password: _enteredPassword,
        );

        if (loginResult['success']) {
          // Decode and print the token for debugging
          final token = loginResult['token'];
          if (token != null && token.isNotEmpty) {
            final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
            print('--- DECODED TOKEN ---');
            print(jsonEncode(decodedToken));
            print('---------------------');
          }

          // Ensure the token exists before proceeding
          if (loginResult['token'] == null || loginResult['token'].isEmpty) {
            if (mounted) {
              final responseData = loginResult['data']?.toString() ?? 'No data received.';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Login successful, but no token was found in the server response. Received: $responseData'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          // Check if a user ID is stored in TokenService
          final storedUserId = await TokenService.getUserId();
          if (storedUserId == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login successful, but User ID could not be determined.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          // Hardcoded admin check
          if (_enteredUsername.toLowerCase() == 'admin') {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/admin-dashboard');
            }
            return;
          }

          // Check if user is admin (you might need to modify this based on your backend response)
          bool isAdmin = false; // You'll need to implement this based on your backend

          if (isAdmin) {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/admin-dashboard');
            }
            return;
          }

        // After successful login, navigate based on selected role
        if (mounted) {
          if (_selectedRoles.contains('runner')) {
            Navigator.of(context).pushReplacementNamed('/runner-home');
          } else {
            Navigator.of(context).pushReplacementNamed('/poster-home');
          }
        }
      } else {
          // Show error message from backend
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loginResult['error']),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // For signup, use Spring backend
        final registerResult = await _authService.registerWithBackend(
          username: _enteredUsername,
          firstName: _enteredFirstName,
          lastName: _enteredLastName,
          email: _enteredEmail,
          password: _enteredPassword,
          phoneNumber: _enteredPhoneNumber,
        );

        if (registerResult['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registration successful! Please login.'),
                backgroundColor: Colors.green,
              ),
            );
            // Switch to login mode
            setState(() {
              _isLogin = true;
              _selectedRoles.clear();
            });
          }
        } else {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(registerResult['error']),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        // Show the actual error instead of a generic message
        final errorMessage = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _isLogin ? _buildLoginCard() : _buildSignupStepper(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}