import 'package:flutter/material.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/forgot_password_page.dart';
import 'package:taurusai/screens/home_page.dart';
import 'package:taurusai/screens/resume_upload_screen.dart';
import 'package:taurusai/screens/signup_screen.dart';
import 'package:taurusai/screens/user_details_form.dart';
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
  String otp = '';
  bool isLoading = false;
  bool obscurePassword = true;
  bool isPhoneNumber = false;
  bool otpSent = false;

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

  bool _checkIfPhoneNumber(String value) {
    return RegExp(r'^\d{10}$').hasMatch(value);
  }

  Future<void> _sendOtp() async {
    setState(() {
      isLoading = true;
      otpSent = true;
    });

    try {
      await _auth.sendOtp(input); // Simulate OTP sending
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to $input'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to send OTP: ${e.toString()}');
    }

    setState(() => isLoading = false);
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        User? user;
        if (isPhoneNumber) {
          // If phone number is detected and OTP is not yet sent, send OTP
          if (!otpSent) {
            await _sendOtp();
            return;
          } else {
            user = await _auth.verifyOtp(input, otp);
          }
        } else {
          user = await _auth.signInWithEmailAndPassword(input, password);
        }

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
      // Using SafeArea and SingleChildScrollView for better layout on various devices
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top left app name
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
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                // Tagline text
                Text(
                  'Sign in to your account and continue your job search',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 30),
                // Decorated container for email/phone input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email or Phone Number',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        input = value;
                        isPhoneNumber = _checkIfPhoneNumber(value);
                        otpSent = false; // Reset OTP if input changes
                      });
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Enter email or phone number' : null,
                  ),
                ),
                SizedBox(height: 20),
                // Password field (if email) or OTP field (if phone and OTP has been sent)
                if (!isPhoneNumber || (isPhoneNumber && !otpSent))
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
                  )
                else if (isPhoneNumber && otpSent)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Enter OTP',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: (value) => setState(() => otp = value),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter OTP' : null,
                    ),
                  ),
                SizedBox(height: 10),
                // Forgot Password
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
                // Login Button
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    isPhoneNumber && !otpSent ? 'Send OTP' : 'Login',
                  ),
                ),
                SizedBox(height: 20),
                // OR divider
                Center(child: Text('OR')),
                SizedBox(height: 20),
                // Login with Google Button
                ElevatedButton(
                  onPressed: _handleGoogleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Login with Google'),
                ),
                SizedBox(height: 30),
                // Existing User? Sign in text (navigates to signup screen)
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Existing User? '),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupScreen()),
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
