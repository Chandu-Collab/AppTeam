import 'package:flutter/material.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/login_screen.dart';
import 'package:taurusai/screens/otp_verification_screen.dart';
import 'package:taurusai/screens/user_details_form.dart';
import 'package:taurusai/services/auth_service.dart';
import 'package:taurusai/widgets/button_widget.dart';

/// A reusable button widget that supports a loading state and an optional icon.
class ReusableButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;

  const ReusableButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.backgroundColor = Colors.orange,
    this.textColor = Colors.white,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onPressed,
      child: isLoading
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
              strokeWidth: 2,
            )
          : icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon!,
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                  ],
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);
  
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
  bool isEmailLoading = false;   // Loading state for email/phone sign up
  bool isGoogleLoading = false;    // Loading state for Google sign up
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  
  // State variable for the checkbox.
  bool isTermsAccepted = false;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Function to show a dialog if terms are not accepted.
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Terms and Conditions"),
          content: const Text("Please check the terms and conditions of Taurusai."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Okay"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Taurusai" text with a logo aligned to the left.
                const Text(
                  'Taurusai',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'images/hkbk_logo.png', // Replace with your logo asset path.
                    height: 50,
                  ),
                ),
                const SizedBox(height: 40),
                // "Ready to join us, User!" text aligned to the left.
                const Text(
                  'Ready to join us, User!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 20),
                // Subtitle text aligned to the left.
                const Text(
                  'Step into Success: “Experience a smarter way to search for jobs and shape your career."',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 40),
                // Email or Phone input field.
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email or Phone',
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          email.contains('@')
                              ? Icons.email
                              : (phoneNumber.isNotEmpty ? Icons.phone : Icons.email),
                        ),
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
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter email or phone' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Password and Confirm Password fields (for email sign up).
                if (email.isNotEmpty) ...[
                  // Password Field with an icon.
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
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !isPasswordVisible,
                        onChanged: (value) => setState(() => password = value),
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
                  // Confirm Password Field with an icon.
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
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isConfirmPasswordVisible = !isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !isConfirmPasswordVisible,
                        onChanged: (value) => setState(() => confirmPassword = value),
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
                // Regular Sign Up button.
                ReusableButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Check if terms have been accepted.
                      if (!isTermsAccepted) {
                        _showTermsDialog();
                        return;
                      }
                      setState(() => isEmailLoading = true);
                      try {
                        User? user;
                        if (email.isNotEmpty) {
                          user = await _auth.registerWithEmailAndPassword(email, password);
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
                          setState(() => isEmailLoading = false);
                          return;
                        }
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailsForm(user: user!),
                            ),
                          );
                        } else {
                          _showErrorSnackBar('Sign up failed. Please try again.');
                        }
                      } catch (e) {
                        _showErrorSnackBar('Error: ${e.toString()}');
                      }
                      setState(() => isEmailLoading = false);
                    }
                  },
                  text: 'Sign Up',
                  isLoading: isEmailLoading,
                  backgroundColor: Colors.orange,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 20),
                // OR divider.
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),
                // Google Sign Up button with a custom Google icon.
                ReusableButton(
                  onPressed: () async {
                    setState(() => isGoogleLoading = true);
                    try {
                      User? user = await _auth.signInWithGoogle();
                      if (user != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailsForm(user: user),
                          ),
                        );
                      } else {
                        _showErrorSnackBar('Google sign up failed. Please try again.');
                      }
                    } catch (e) {
                      _showErrorSnackBar('Error: ${e.toString()}');
                    }
                    setState(() => isGoogleLoading = false);
                  },
                  text: 'Sign Up with Google',
                  isLoading: isGoogleLoading,
                  backgroundColor: Colors.orange,
                  textColor: Colors.white,
                  // Replace the default icon with a custom asset image.
                  icon: Image.asset(
                    'images/icons8_google_48.png', // Replace with your asset path.
                    height: 24,
                    width: 24,
                  ),
                ),
                const SizedBox(height: 20),
                // Terms and Conditions text with checkbox, centered.
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isTermsAccepted,
                        onChanged: (value) {
                          setState(() {
                            isTermsAccepted = value ?? false;
                          });
                        },
                      ),
                      Flexible(
                        child: Text(
                          'By clicking register, you agree to the Terms and Conditions & Privacy Policy of Taurusai',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Existing User? Sign in text, centered.
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Existing User? ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
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
