import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanlythuvienck/providers/auth_provider.dart';
import 'package:quanlythuvienck/providers/book_provider.dart';
import 'package:quanlythuvienck/screens/auth/login_screen.dart';
import 'package:quanlythuvienck/services/firebase_service.dart';
import 'package:quanlythuvienck/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase(); // Sửa tên phương thức
  await NotificationService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
      child: MaterialApp(
        title: 'Thư viện',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
