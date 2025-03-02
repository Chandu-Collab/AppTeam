import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/forgot_password_page.dart';
import 'package:taurusai/screens/home_page.dart';
import 'package:taurusai/screens/resume_upload_screen.dart';
import 'package:taurusai/screens/signup_screen.dart';
import 'package:taurusai/screens/user_details_form.dart';
import 'package:taurusai/screens/otp_verification_screen.dart';
import 'package:taurusai/services/auth_service.dart';
import 'package:taurusai/services/user_service.dart';
import 'package:taurusai/widgets/input_widget.dart'; // Provides buildTextField
import '../widgets/button_widget.dart'; // Provides buildButton

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields.
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String input = '';
  String password = '';
  bool isLoading = false;
  bool obscurePassword = true;
  bool isPhoneNumber = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      setState(() {
        input = _inputController.text;
        isPhoneNumber = _checkIfPhoneNumber(input);
      });
    });
    _passwordController.addListener(() {
      setState(() {
        password = _passwordController.text;
      });
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _navigateToNextScreen(User user) {
    if (user.isProfileComplete == null || !user.isProfileComplete!) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserDetailsForm(user: user)),
      );
    } else if (user.hasResume == null || !user.hasResume!) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResumeUploadScreen(user: user)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(user: user)),
      );
    }
  }

  // Validate if the input is a valid phone number in E.164 format.
  bool _checkIfPhoneNumber(String value) {
    return RegExp(r'^\+\d{10,15}$').hasMatch(value.trim());
  }

  // For phone logins, send the OTP and navigate.
  Future<void> _sendOtpAndNavigate() async {
    setState(() => isLoading = true);
    try {
      // Uncomment and implement OTP sending logic if needed.
      String verificationId = await _auth.sendOtp(input);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            verificationId: verificationId,
            phoneNumber: input,
            isSignUp: false,
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to send OTP: ${e.toString()}');
    }
    setState(() => isLoading = false);
  }

  // Handles login for both email and phone.
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      if (isPhoneNumber) {
        await _sendOtpAndNavigate();
      } else {
        setState(() => isLoading = true);
        try {
          User? user = await _auth.signInWithEmailAndPassword(input, password);
          if (user != null) {
            User? fullUser = await _userService.getUserById(user.id);
            if (fullUser != null) {
              _navigateToNextScreen(fullUser);
            } else {
              _showErrorSnackBar('Error fetching user data. Please try again.');
            }
          } else {
            _showErrorSnackBar('Login failed. Check your credentials and try again.');
          }
        } catch (e) {
          _showErrorSnackBar('Error: ${e.toString()}');
        }
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      User? user = await _auth.signInWithGoogle();
      if (user != null) {
        User? fullUser = await _userService.getUserById(user.id);
        if (fullUser != null) {
          _navigateToNextScreen(fullUser);
        } else {
          _showErrorSnackBar('Error fetching user data. Please try again.');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Google login failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea and SingleChildScrollView for responsiveness.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App name
                Text(
                  'Taurusai',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                // Logo positioned below the Taurusai text and aligned to the left.
                Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'images/hkbk_logo.png', // Replace with your logo asset path.
                    height: 50,
                  ),
                ),
                SizedBox(height: 30),
                // Welcome text
                Text(
                  'Welcome Back! User',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                // Tagline
                Text(
                  'Your Next Chapter Begins Here: “Sign in and explore opportunities that can transform your future".',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 30),
                // Using buildTextField for Email/Phone input with email icon.
                buildTextField(
                  'Email or Phone Number (e.g., +11234567890)',
                  _inputController,
                  (value) => value!.isEmpty ? 'Enter email or phone number' : null,
                  (value) {},
                  icon: Icons.email,
                ),
                SizedBox(height: 20),
                // Using buildTextField for Password (if email is used) with lock icon.
                if (!isPhoneNumber)
                  buildTextField(
                    'Password',
                    _passwordController,
                    (value) =>
                        value!.length < 6 ? 'Password must be at least 6 characters' : null,
                    (value) {},
                    isPassword: true,
                    icon: Icons.lock,
                  ),
                // Forgot password link (only for email login)
                if (!isPhoneNumber)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                        );
                      },
                      child: Text('Forgot Password?'),
                    ),
                  ),
                SizedBox(height: 20),
                // Login button using the custom buildButton widget.
                buildButton(isLoading ? null : _handleLogin,
                    text: isPhoneNumber ? 'Send OTP' : 'Login'),
                SizedBox(height: 20),
                // OR divider
                Center(child: Text('OR')),
                SizedBox(height: 20),
                // Google login button using ElevatedButton.icon with the updated Google icon.
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _handleGoogleLogin,
                  icon: Image.asset(
                    'images/icons8_google_48.png', // Replace with your custom Google icon asset path.
                    height: 24,
                  ),
                  label: Text(
                    'Login with Google',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: 30),
                // Sign up navigation
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Existing User? '),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SignupScreen()),
                          );
                        },
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
