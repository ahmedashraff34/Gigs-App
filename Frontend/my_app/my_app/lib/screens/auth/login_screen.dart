import 'package:ali_grad/models/user_model.dart';
import 'package:ali_grad/widgets/inputBox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/theme.dart';
import '../../services/user_service.dart';
import '../../utils/validation.dart';
import '../admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  UserService userService = UserService();
  String selectedRole = 'poster';

  // Validation error states
  String? usernameError;
  String? passwordError;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    // Clear previous errors
    setState(() {
      usernameError = null;
      passwordError = null;
    });

    // Validate fields
    final usernameValidation = ValidationUtils.validateLoginUsername(usernameController.text);
    final passwordValidation = ValidationUtils.validateLoginPassword(passwordController.text);

    // Update error states
    setState(() {
      usernameError = usernameValidation;
      passwordError = passwordValidation;
    });

    // Check if any validation failed
    if (usernameValidation != null || passwordValidation != null) {
      return; // Stop submission if validation failed
    }

    // If all validation passed, proceed with login
    _submitLogin();
  }

  void _submitLogin() async {
    // Set role to admin if username is admin
    String roleToUse = selectedRole;
    if (usernameController.text.trim() == 'admin') {
      roleToUse = 'admin';
    }

    final response = await userService.loginUser(
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
      selectedRole: roleToUse,
    );

    print(response);

    if (response) {
      if (usernameController.text.trim() == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      } else {
        Navigator.pushNamed(context, "/$selectedRole-home");
      }
    } else {
      // Show error message if login failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check your credentials.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Container(
        color: AppTheme.primaryColor.withValues(alpha: .7),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: SvgPicture.asset(
                "assets/svg/login.svg",
                height: 120,
                width: 120,
                color: Colors.white,
              ),
            ),
            Expanded(
              flex: 11,
              child: Container(
                padding: EdgeInsets.all(AppTheme.paddingHuge),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(90),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Login",
                                style: AppTheme.textStyle0.copyWith(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Spacer(),
                              SizedBox(height: AppTheme.paddingMedium),

                              /// Username
                              InputBox(
                                obscure: false,
                                label: "Username",
                                hintText: "Enter your username",
                                controller: usernameController,
                                errorText: usernameError,
                                keyboardType: TextInputType.text,
                              ),
                              SizedBox(height: AppTheme.paddingMedium),

                              /// Password
                              InputBox(
                                obscure: true,
                                label: "Password",
                                hintText: "Enter your password",
                                controller: passwordController,
                                errorText: passwordError,
                                keyboardType: TextInputType.visiblePassword,
                              ),
                              SizedBox(height: AppTheme.paddingMedium),
                              Row(
                                children: [
                                  SizedBox(width: AppTheme.paddingHuge),
                                  Expanded(
                                    child: FloatingActionButton(
                                      heroTag: "posterTag",
                                      elevation: 0,
                                      onPressed: () {
                                        setState(() {
                                          selectedRole = "poster";
                                        });
                                      },
                                      backgroundColor: selectedRole == "poster"
                                          ? AppTheme.primaryColor
                                          : AppTheme.disabledColor,
                                      child: Text(
                                        "Poster",
                                        style: AppTheme.textStyle2.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.paddingMedium),
                                  Expanded(
                                    child: FloatingActionButton(
                                      heroTag: "runnerTag",
                                      elevation: 0,
                                      onPressed: () {
                                        setState(() {
                                          selectedRole = "runner";
                                        });
                                      },
                                      backgroundColor: selectedRole == "runner"
                                          ? AppTheme.primaryColor
                                          : AppTheme.disabledColor,
                                      child: Text(
                                        "Runner",
                                        style: AppTheme.textStyle2
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.paddingHuge),
                                ],
                              ),
                              Spacer(),
                              SizedBox(height: AppTheme.paddingMedium),

                              /// Login Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: AppTheme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  _validateAndSubmit();
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: AppTheme.paddingMedium),

                              /// Sign Up Link
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/register');
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Don't have any account? ",
                                      style: AppTheme.textStyle1.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Sign Up",
                                          style: AppTheme.textStyle1.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
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
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
