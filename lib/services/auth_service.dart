import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taurusai/models/user.dart' as AppUser;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This variable stores the verificationId received after sending OTP.
  String? _verificationId;

  // Convert Firebase User to App User
  Future<AppUser.User?> _userFromFirebaseUser(User? user) async {
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('taurusai')
            .doc('users')
            .collection('accounts')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = user.uid; // Ensure the id is set
          return AppUser.User.fromJson(data);
        } else {
          // User document doesn't exist, create a new one
          AppUser.User newUser = AppUser.User(
            id: user.uid,
            userName: user.displayName ?? '',
            profileName: user.displayName ?? '',
            email: user.email ?? '',
            mobile: user.phoneNumber ?? '',
            isProfileComplete: false,
            hasResume: false,
          );
          await _firestore
              .collection('taurusai')
              .doc('users')
              .collection('accounts')
              .doc(user.uid)
              .set(newUser.toJson());
          return newUser;
        }
      } catch (e) {
        print('Error fetching user data: $e');
        return null;
      }
    }
    return null;
  }

  // Email & Password Sign In
  Future<AppUser.User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return await _userFromFirebaseUser(user);
    } catch (e) {
      print('Error signing in with email and password: $e');
      return null;
    }
  }

  // Email & Password Registration
  Future<AppUser.User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return await _userFromFirebaseUser(user);
    } catch (e) {
      print('Error signing up with email and password: $e');
      return null;
    }
  }

  // Google Sign In
  Future<AppUser.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;
      return await _userFromFirebaseUser(user);
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Phone Number Sign In (auto verification callback)
  Future<void> verifyPhoneNumber(
      String phoneNumber, Function(String) codeSent, {required Null Function(dynamic error) onError}) async {
    // Ensure the phone number is in E.164 format.
    if (!phoneNumber.startsWith('+')) {
      throw Exception(
          "Phone number must include country code (e.g. '+11234567890').");
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Optionally, you can sign in the user automatically here.
        UserCredential result = await _auth.signInWithCredential(credential);
        User? user = result.user;
        await _userFromFirebaseUser(user);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Sign In with OTP (using the stored verificationId)
  Future<AppUser.User?> signInWithOTP(
      String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;
      return await _userFromFirebaseUser(user);
    } catch (e) {
      print('Error signing in with OTP: $e');
      return null;
    }
  }

  // Sends OTP to the given phone number.
  // The phone number must be provided in international format (E.164), e.g. "+11234567890".
  Future<String> sendOtp(String phoneNumber) async {
    // Ensure phone number is in E.164 format.
    if (!phoneNumber.startsWith('+')) {
      throw Exception(
          "Phone number must include country code in E.164 format (e.g., '+11234567890').");
    }
    Completer<String> completer = Completer<String>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Optionally, you can sign in the user automatically here.
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
    return completer.future;
  }

  // Verifies the OTP using the stored verificationId.
  Future<AppUser.User?> verifyOtp(String phoneNumber, String otp) async {
    // Ensure phone number is in E.164 format.
    if (!phoneNumber.startsWith('+')) {
      throw Exception(
          "Phone number must include country code in E.164 format (e.g., '+11234567890').");
    }
    if (_verificationId == null) {
      throw Exception("No verification ID available. Please request an OTP first.");
    }
    return await signInWithOTP(_verificationId!, otp);
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<bool> isProfileComplete(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('taurusai')
          .doc('users')
          .collection('profiles')
          .doc(userId)
          .get();
      return doc.exists &&
          (doc.data() as Map<String, dynamic>)['isProfileComplete'] == true;
    } catch (e) {
      print('Error checking profile completion: $e');
      return false;
    }
  }

  Future<AppUser.User?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return await _userFromFirebaseUser(firebaseUser);
    }
    return null;
  }

  verifyOTP(String verificationId, String otp) {}
}
