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

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  String input = '';
  String password = '';
  bool isLoading = false;
  bool obscurePassword = true;
  bool isPhoneNumber = false;

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

  // Validate if the input is a valid phone number in E.164 format (e.g., +11234567890)
  bool _checkIfPhoneNumber(String value) {
    return RegExp(r'^\+\d{10,15}$').hasMatch(value.trim());
  }

  // For phone logins, send the OTP and navigate to OTPVerificationScreen.
  Future<void> _sendOtpAndNavigate() async {
    setState(() => isLoading = true);
    try {
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

  // Handles login for both email and phone logins.
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
      // SafeArea and SingleChildScrollView ensure a responsive layout.
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
                  'Figma',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
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
                  'We are here to help you to find your Dream job!, Join us now',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 30),
                // Email or Phone input field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email or Phone Number (e.g., +11234567890)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        input = value;
                        // Determine if the input is a valid phone number in E.164 format.
                        isPhoneNumber = _checkIfPhoneNumber(value);
                      });
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Enter email or phone number' : null,
                  ),
                ),
                SizedBox(height: 20),
                // Password field for email login only.
                if (!isPhoneNumber)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: obscurePassword,
                      onChanged: (value) => setState(() => password = value),
                      validator: (value) => value!.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                  ),
                // Forgot password link (only for email login)
                if (!isPhoneNumber)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage()),
                        );
                      },
                      child: Text('Forgot Password?'),
                    ),
                  ),
                SizedBox(height: 20),
                // Login button: for phone login it sends OTP and navigates; for email login, it proceeds normally.
                ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(isPhoneNumber ? 'Send OTP' : 'Login'),
                ),
                SizedBox(height: 20),
                // OR divider
                Center(child: Text('OR')),
                SizedBox(height: 20),
                // Google login button
                ElevatedButton(
                  onPressed: isLoading ? null : _handleGoogleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Login with Google'),
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
                          Navigator.push(
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
