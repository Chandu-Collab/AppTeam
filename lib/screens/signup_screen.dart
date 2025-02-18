import 'package:flutter/material.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/login_screen.dart';
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
  String confirmPassword = '';
  String phoneNumber = '';
  bool isEmailLoading = false;   // Separate loading state for email/phone sign up
  bool isGoogleLoading = false;  // Separate loading state for Google sign up
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Custom button colors
    Color signupButtonColor = Colors.grey; // For Sign Up button background
    Color signupButtonTextColor = Colors.blue; // For Sign Up button text
    Color googleButtonColor = Colors.grey; // For Sign Up with Google button background
    Color googleButtonTextColor = Colors.blue; // For Sign Up with Google button text

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App name "Figma" at top left
                const Text(
                  'Figma',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                // "Get started with Figma!" centered
                const Center(
                  child: Text(
                    'Get started with Figma!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                // Subtitle text centered
                const Center(
                  child: Text(
                    'Choose a job you love, and you never have to work a day in your life',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                // Email or Phone input field in decorated box
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email or Phone',
                        border: InputBorder.none,
                      ),
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter email or phone'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Password and Confirm Password fields (displayed for email sign up)
                if (email.isNotEmpty) ...[
                  // Password Field
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !isPasswordVisible,
                        onChanged: (value) =>
                            setState(() => password = value),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password Field
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                isConfirmPasswordVisible =
                                    !isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !isConfirmPasswordVisible,
                        onChanged: (value) =>
                            setState(() => confirmPassword = value),
                        validator: (value) {
                          if (value != password) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // Sign Up Elevated Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: signupButtonColor,
                      foregroundColor: signupButtonTextColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        setState(() => isEmailLoading = true);
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
                                    builder: (context) =>
                                        OTPVerificationScreen(
                                      verificationId: verificationId,
                                      phoneNumber: phoneNumber,
                                      isSignUp: true,
                                    ),
                                  ),
                                );
                              },
                            );
                            setState(() => isEmailLoading = false);
                            return;
                          }
                          if (user != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailsForm(user: user!),
                              ),
                            );
                          } else {
                            _showErrorSnackBar(
                                'Sign up failed. Please try again.');
                          }
                        } catch (e) {
                          _showErrorSnackBar('Error: ${e.toString()}');
                        }
                        setState(() => isEmailLoading = false);
                      }
                    },
                    child: isEmailLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                signupButtonTextColor),
                          )
                        : const Text('Sign Up'),
                  ),
                ),
                const SizedBox(height: 20),
                // OR divider
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Sign Up with Google Elevated Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: googleButtonColor,
                      foregroundColor: googleButtonTextColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      setState(() => isGoogleLoading = true);
                      try {
                        User? user = await _auth.signInWithGoogle();
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserDetailsForm(user: user),
                            ),
                          );
                        } else {
                          _showErrorSnackBar(
                              'Google sign up failed. Please try again.');
                        }
                      } catch (e) {
                        _showErrorSnackBar('Error: ${e.toString()}');
                      }
                      setState(() => isGoogleLoading = false);
                    },
                    child: isGoogleLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                googleButtonTextColor),
                          )
                        : const Text('Sign Up with Google'),
                  ),
                ),
                const SizedBox(height: 20),
                // Terms and Conditions text
                const Center(
                  child: Text(
                    'By clicking register, you agree to the Terms and Conditions & Privacy Policy of Figma',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                // Existing User? Sign in text
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Existing User? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: const Text('Sign in'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
