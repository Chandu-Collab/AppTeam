import 'package:flutter/material.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/home_page.dart';
import 'package:taurusai/screens/user_details_form.dart';
import 'package:taurusai/services/auth_service.dart';
import 'package:taurusai/services/user_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final bool isSignUp;

  OTPVerificationScreen({
    required this.verificationId,
    required this.phoneNumber,
    this.isSignUp = false,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _otp = '';
  bool isLoading = false;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTP Verification')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Enter the OTP sent to ${widget.phoneNumber}'),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'OTP'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _otp = value,
                validator: (value) => value!.isEmpty ? 'Enter OTP' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Verify OTP'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => isLoading = true);
                    try {
                      User? user = await _auth.signInWithOTP(
                          widget.verificationId, _otp);
                      if (user != null) {
                        User fullUser =
                            (await UserService().getUserById(user.id))!;
                        if (widget.isSignUp || !fullUser.isProfileComplete!) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailsForm(user: fullUser)),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage(user: fullUser)),
                          );
                        }
                      } else {
                        _showErrorSnackBar(
                            'OTP verification failed. Please try again.');
                      }
                    } catch (e) {
                      _showErrorSnackBar('Error: ${e.toString()}');
                    }
                    setState(() => isLoading = false);
                  }
                },
              ),
              if (isLoading) CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
