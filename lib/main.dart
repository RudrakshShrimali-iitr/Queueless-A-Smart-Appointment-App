// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// ✅ Add this import
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qless_app/bloc/booking/booking_bloc.dart';
import 'package:qless_app/booking_repository.dart';
import 'package:qless_app/merchant%20side/merchant_dashboard.dart';
import 'package:qless_app/services/booking_service.dart';
import 'merchant side/business_form.dart';
import 'package:qless_app/customer side/customer_page.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<BookingBloc>(
          create: (context) => BookingBloc(
            bookingRepository: BookingRepository(),
            bookingService: BookingService(),
          ),
        ),
        // Add other providers if needed
      ],
      child: QueueLessApp(),
    ),
  );
}

// ✅ Handle foreground messages
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
