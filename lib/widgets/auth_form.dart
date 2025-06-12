import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qless_app/merchant%20side/business_form.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
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
              CustomTextField(
                controller: _emailController,
                labelText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                 if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
  return 'Please enter a valid email';
}
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: !isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(
                      () => isPasswordVisible = !isPasswordVisible),
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
              SubmitButton(
                isLogin: widget.isLogin,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _handleSubmission();
                  }
                },
              ),
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
        style: TextStyle(
            color: Color(0xFF667eea), fontWeight: FontWeight.w500),
      ),
    );
  }

 void _handleSubmission() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final name = _nameController.text.trim();
  final role = selectedRole;

  try {
    if (widget.isLogin) {
      // LOGIN FLOW
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .get();

      final storedRole = userDoc.get('role') as String;

      if (storedRole == 'customer') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => CustomerHomePage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => BusinessSetupForm ()),
        );
      }
    } else {
      
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': Timestamp.now(),
      });

      // Show success message and go to login screen
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
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
}

