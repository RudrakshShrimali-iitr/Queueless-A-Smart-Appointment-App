import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qless_app/bloc/user/user_bloc.dart';
import 'package:qless_app/bloc/user/user_event.dart';
import 'package:qless_app/merchant%20side/business_form.dart';
import 'package:qless_app/merchant%20side/merchant_dashboard.dart';
import 'package:qless_app/customer side/customer_page.dart';
import 'package:qless_app/screens/auth_screen.dart';
import '../services/auth_service.dart';
import '../merchant side/role_selector.dart';
import 'custom_text_field.dart';
import '../login sign up pages/submit_button.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;

  const AuthForm({required this.isLogin});

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  String selectedRole = 'customer';
  bool isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController(); // 👈 New phone controller

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose(); // 👈 Dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RoleSelector(
                selectedRole: selectedRole,
                onRoleChanged: (role) => setState(() => selectedRole = role),
              ),
              SizedBox(height: 24),

              // Full Name for Sign-Up
              if (!widget.isLogin) ...[
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
              ],

              // Phone number only for customers during sign-up
              if (!widget.isLogin && selectedRole == 'customer') ...[
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
              ],

              // Email
              CustomTextField(
                controller: _emailController,
                labelText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Password
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: !isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => isPasswordVisible = !isPasswordVisible),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              // Confirm Password for Sign-Up
              if (!widget.isLogin) ...[
                SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
              SizedBox(height: 24),

              // Submit button
              SubmitButton(
                isLogin: widget.isLogin,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _handleSubmission();
                  }
                },
              ),

              // Forgot password for login
              if (widget.isLogin) ...[
                SizedBox(height: 16),
                _buildForgotPassword(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Forgot password functionality')),
        );
      },
      child: Text(
        'Forgot Password?',
        style: TextStyle(color: Color(0xFF667eea), fontWeight: FontWeight.w500),
      ),
    );
  }

  void _handleSubmission() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final role = selectedRole;
    final phone = _phoneController.text.trim(); // 👈 Get phone input

    try {
      if (widget.isLogin) {
        // LOGIN FLOW
        UserCredential userCred = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        final uid = userCred.user!.uid;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        final userData = userDoc.data() as Map<String, dynamic>;
        final storedRole = userData['role'] as String;

        if (storedRole == 'customer') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => UserBloc()..add(LoadUser(uid)),
                child: CustomerHomePage(),
              ),
            ),
          );
        } else if (storedRole == 'merchant') {
          if (userData.containsKey('businessId') &&
              userData['businessId'] != null) {
            final businessId = userData['businessId'];
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) =>
                    MerchantDashboard(businessId: businessId, merchantId: uid),
              ),
            );
          } else {
            final businessSnap = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('businesses')
                .get();

            if (businessSnap.docs.isNotEmpty) {
              final businessId = businessSnap.docs.first.id;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .update({'businessId': businessId});

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => MerchantDashboard(
                    merchantId: uid,
                    businessId: businessId,
                  ),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => BusinessSetupForm()),
              );
            }
          }
        }
      } else {
        // SIGN-UP FLOW
        UserCredential cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final uid = cred.user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'role': role,
          'createdAt': Timestamp.now(),
          if (role == 'customer') 'phone': phone, // 👈 Only save if customer
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-up successful! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => AuthScreen(isLogin: true)),
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication error')),
      );
    } catch (e, stackTrace) {
      print('Unknown error: $e');
      print('Stack trace: $stackTrace');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
