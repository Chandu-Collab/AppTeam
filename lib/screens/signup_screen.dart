import 'package:flutter/material.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/otp_verification_screen.dart';
import 'package:taurusai/screens/user_details_form.dart';
import 'package:taurusai/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _auth = AuthService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
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
                child: Text('Sign Up'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => isLoading = true);
                    try {
                      User? user;
                      if (email.isNotEmpty) {
                        user = await _auth.registerWithEmailAndPassword(
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
                                  isSignUp: true,
                                ),
                              ),
                            );
                          },
                        );
                        return;
                      }
                      if (user != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UserDetailsForm(user: user!)),
                        );
                      } else {
                        _showErrorSnackBar('Sign up failed. Please try again.');
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
                child: Text('Sign Up with Google'),
                onPressed: () async {
                  setState(() => isLoading = true);
                  try {
                    User? user = await _auth.signInWithGoogle();
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserDetailsForm(user: user)),
                      );
                    } else {
                      _showErrorSnackBar(
                          'Google sign up failed. Please try again.');
                    }
                  } catch (e) {
                    _showErrorSnackBar('Error: ${e.toString()}');
                  }
                  setState(() => isLoading = false);
                },
              ),
              if (isLoading) Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
