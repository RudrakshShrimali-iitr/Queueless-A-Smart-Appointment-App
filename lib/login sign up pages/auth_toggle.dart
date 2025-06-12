import 'package:flutter/material.dart';

class AuthToggle extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onToggle;

  const AuthToggle({
    required this.isLogin,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? "Don't have an account? " : "Already have an account? ",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        TextButton(
          onPressed: onToggle,
          child: Text(
            isLogin ? 'Sign Up' : 'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}