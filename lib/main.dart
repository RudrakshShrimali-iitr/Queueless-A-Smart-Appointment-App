// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qless_app/merchant%20side/merchant_dashboard.dart';
import 'merchant side/business_form.dart';
import 'package:qless_app/customer side/customer_page.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  await FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: true,
  );
  runApp(QueueLessApp());
}

class QueueLessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QueueLess',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      home: AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
