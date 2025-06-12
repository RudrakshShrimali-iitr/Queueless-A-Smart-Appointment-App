// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onPressed;

  const SubmitButton({
    required this.isLogin,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF667eea),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Color(0xFF667eea).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isLogin ? 'Sign In' : 'Create Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}