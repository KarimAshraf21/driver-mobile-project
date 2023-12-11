// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _loading = false;

  // Custom validation function for email domain
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    // Check if the email has the correct domain
    if (!value.endsWith('@eng.asu.edu.eg')) {
      return 'Only eng.asu.edu.eg domain is allowed';
    }

    return null;
  }

  // Check if the email is already registered
  Future<bool> _isEmailRegistered(String email) async {
    try {
      final result = await _auth.fetchSignInMethodsForEmail(email);
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/logo.png'),
                  ),
                  const Text(
                    "ASU Campus Cab Driver",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  _buildInputField(
                    icon: Icons.person,
                    controller: _nameController,
                    hintText: 'Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  _buildInputField(
                    icon: Icons.phone,
                    controller: _numberController,
                    hintText: 'Number',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your number';
                      }
                      return null;
                    },
                  ),
                  _buildInputField(
                    icon: Icons.email,
                    controller: _emailController,
                    hintText: 'Email',
                    validator: _validateEmail,
                  ),
                  _buildInputField(
                    icon: Icons.lock,
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      // Add password validation logic if needed
                      return null;
                    },
                  ),
                  _buildSignupButton(),
                  _buildLoginButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: controller,
                obscureText: obscureText,
                validator: validator,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _loading = true;
          });

          final email = _emailController.text;

          final isEmailRegistered = await _isEmailRegistered(email);

          if (isEmailRegistered) {
            _showErrorMessage('Email is already registered');
          } else {
            try {
              UserCredential userCredential =
                  await _auth.createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text,
              );

              // await _auth.currentUser?.sendEmailVerification();
              print("+++++++++++++++++++++++++++++");

              // Store additional user data in Firestore
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .set({
                'firstName': _nameController.text,
                'email': _emailController.text,
                'phone': _numberController.text,
                'id': _emailController.text.split('@').first,
                // Do not add 'rideHistory' here
              });

// Add a rideHistory document inside the user's subcollection
              String rideId = 'your_ride_id'; // Replace with the actual ride ID
              String driverId =
                  'your_driver_id'; // Replace with the actual driver ID

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .collection('rideHistory')
                  .doc(
                      rideId) // Use rideId as the document ID in the subcollection
                  .set({
                'driverId': driverId,
                // Other fields you may want to include, initially empty or null
                'status': null,
                'someOtherField': null,
                // ...
              });

              print("=====================================");
              await FirebaseFirestore.instance
                  .collection('drivers')
                  .doc(userCredential.user!.uid)
                  .set({
                'firstName': _nameController.text,
                'email': _emailController.text,
                'phone': _numberController.text,
                'id': _emailController.text.split('@').first,
              });

              Navigator.pushReplacementNamed(context, '/home');
            } catch (e) {
              print('Error: $e');
              _showErrorMessage('$e');
            }
          }

          setState(() {
            _loading = false;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
      ),
      child: _loading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("Signup", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: const Text(
        "Login",
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
