import 'package:flutter/material.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/forgot_password_page.dart';
import 'package:taurusai/screens/home_page.dart';
import 'package:taurusai/screens/otp_verification_screen.dart';
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
  String email = '';
  String password = '';
  String phoneNumber = '';
  bool isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email or Phone'),
                onChanged: (value) {
                  setState(() {
                    if (value.contains('@')) {
                      email = value;
                      phoneNumber = '';
                    } else {
                      phoneNumber = value;
                      email = '';
                    }
                  });
                },
                validator: (value) =>
                    value!.isEmpty ? 'Enter email or phone' : null,
              ),
              SizedBox(height: 20),
              if (email.isNotEmpty)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onChanged: (value) => setState(() => password = value),
                  validator: (value) => value!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Login'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => isLoading = true);
                    try {
                      User? user;
                      if (email.isNotEmpty) {
                        user = await _auth.signInWithEmailAndPassword(
                            email, password);
                      } else if (phoneNumber.isNotEmpty) {
                        await _auth.verifyPhoneNumber(
                          phoneNumber,
                          (verificationId) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OTPVerificationScreen(
                                  verificationId: verificationId,
                                  phoneNumber: phoneNumber,
                                ),
                              ),
                            );
                          },
                        );
                        return;
                      }
                      if (user != null) {
                        User? fullUser = user;
                        if (fullUser != null) {
                          _navigateToNextScreen(fullUser);
                        } else {
                          _showErrorSnackBar(
                              'Error fetching user data. Please try again.');
                        }
                      } else {
                        _showErrorSnackBar(
                            'Login failed. Please check your credentials and try again.');
                      }
                    } catch (e) {
                      _showErrorSnackBar('Error: ${e.toString()}');
                    }
                    setState(() => isLoading = false);
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Login with Google'),
                onPressed: () async {
                  setState(() => isLoading = true);
                  try {
                    User? user = await _auth.signInWithGoogle();
                    if (user != null) {
                      User? fullUser = await _userService.getUserById(user.id);
                      if (fullUser != null) {
                        _navigateToNextScreen(fullUser);
                      } else {
                        _showErrorSnackBar(
                            'Error fetching user data. Please try again.');
                      }
                    } else {
                      _showErrorSnackBar(
                          'Google login failed. Please try again.');
                    }
                  } catch (e) {
                    _showErrorSnackBar('Error: ${e.toString()}');
                  }
                  setState(() => isLoading = false);
                },
              ),
              SizedBox(height: 20),
              TextButton(
                child: Text('Don\'t have an account? Sign Up'),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignupScreen())),
              ),
              TextButton(
                child: Text('Forgot Password?'),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordPage())),
              ),
              if (isLoading) Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
