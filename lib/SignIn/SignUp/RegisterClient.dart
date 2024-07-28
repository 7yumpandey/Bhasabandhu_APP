import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:witness_deposition/home.dart';

import '../../Clerk/Admin/ClerkDashboard.dart';


class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _caseNumberController = TextEditingController();
  String _role = 'Victim';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courtroom Translator - Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _caseNumberController,
                decoration: InputDecoration(labelText: 'Case Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a case number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _role,
                items: ['Victim', 'Clerk of Courts/Lawyer', 'Judge']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Role'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
          'email': _emailController.text,
          'caseNumber': _caseNumberController.text,
          'role': _role,
        });

        _sendEmail(_emailController.text, _caseNumberController.text, _role);

        _navigateToHome(userCredential.user!);

      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up: $e')),
        );
      }
    }
  }

  void _sendEmail(String email, String caseNumber, String role) async {
    final smtpServer = gmail('your-email@gmail.com', 'your-email-password');
    final message = Message()
      ..from = Address('your-email@gmail.com', 'Courtroom Translator')
      ..recipients.add(email)
      ..subject = 'Welcome to Courtroom Translator'
      ..text = 'You have been registered as a $role for case number $caseNumber.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Message not sent. \n' + e.toString());
    }
  }

  void _navigateToHome(User user) async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = userDoc.data() as Map<String, dynamic>;
    final role = data['role'];

    if (role == 'Clerk of Courts/Lawyer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ClerkDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SpeechTranslationScreen()),
      );
    }
  }
}
