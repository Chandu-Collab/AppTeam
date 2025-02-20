import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/home_page.dart';
import 'package:taurusai/screens/user_details_form.dart';
import 'package:taurusai/services/auth_service.dart';
import 'package:taurusai/services/user_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final bool isSignUp;

  const OTPVerificationScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
    this.isSignUp = false,
  }) : super(key: key);

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

  // Optional: Implement your resend OTP logic here.
  void _resendOTP() async {
    // For example, you could call _auth.sendOtp(widget.phoneNumber) again.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTP Verification')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Enter the 6-digit OTP sent to ${widget.phoneNumber}'),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'OTP',
                    hintText: 'Enter 6-digit OTP',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onChanged: (value) => _otp = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the OTP';
                    } else if (value.length != 6) {
                      return 'OTP must be 6 digits';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text('Verify OTP'),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => isLoading = true);
                            try {
                              // Use verifyOtp to ensure that the phone number (with country code)
                              // is properly validated before verifying the OTP.
                              User? user = await _auth.verifyOtp(widget.phoneNumber, _otp);
                              if (user != null) {
                                User fullUser = (await UserService().getUserById(user.id))!;
                                if (widget.isSignUp || !fullUser.isProfileComplete!) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserDetailsForm(user: fullUser),
                                    ),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomePage(user: fullUser),
                                    ),
                                  );
                                }
                              } else {
                                _showErrorSnackBar('OTP verification failed. Please try again.');
                              }
                            } catch (e) {
                              _showErrorSnackBar('Error: ${e.toString()}');
                            }
                            setState(() => isLoading = false);
                          }
                        },
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: _resendOTP,
                  child: Text('Resend OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
