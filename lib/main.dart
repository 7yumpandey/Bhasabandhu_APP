import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:witness_deposition/SignIn/SignUp/RegisterClient.dart';
import 'SignIn/SignUp/LogIn.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SingInScreen(),
    );
  }
}

