import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:witness_deposition/SignIn/SignUp/RegisterClient.dart';
import '../../Clerk/Admin/ClerkDashboard.dart';
import '../../home.dart';
import '../../resuablewidget.dart';

class SingInScreen extends StatefulWidget {
  const SingInScreen({super.key});

  @override
  State<SingInScreen> createState() => _SingInScreenState();
}

class _SingInScreenState extends State<SingInScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
    final TextEditingController _casenumberTextController = TextEditingController();
  String _userRole = 'Victim'; // Default role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/images/IndiaCourtMain.jpeg"),
          ),
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).size.height * 0.1, 20, 0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "BHASABANDHU",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 50,
                          backgroundColor: Colors.black12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      logoWidget("assets/images/IndiaCourt2.jpeg"),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        margin: EdgeInsets.all(8.0),
                        width: 350,
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              // Role Toggle Buttons
                              ToggleButtons(
                                isSelected: ['Victim', 'Clerk'].map((role) => _userRole == role).toList(),
                                onPressed: (int index) {
                                  setState(() {
                                    _userRole = ['Victim', 'Clerk'][index];
                                  });
                                },
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('Victim'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('Clerk'),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              reuseBar(
                                "Enter User name",
                                Icons.person_outline_outlined,
                                false,
                                _emailTextController,
                              ),
                              SizedBox(height: 15),
                              reuseBar(
                                "Password",
                                Icons.lock_clock_outlined,
                                true,
                                _passwordTextController,
                              ),
                              SizedBox(height: 15),
                              reuseBar(
                                "Case Number",
                                Icons.numbers_outlined,
                                false,
                                _casenumberTextController,
                              ),
                              SizedBox(height: 10),
                              buttontoUse(context, true, () async {
                                try {
                                  UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                    email: _emailTextController.text,
                                    password: _passwordTextController.text,
                                  );
                                  // Navigate based on the role
                                  if (_userRole == 'Victim') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SpeechTranslationScreen(), // Replace with your Victim home screen
                                      ),
                                    );
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClerkDashboard(), // Replace with your Clerk home screen
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print("Error: ${e.toString()}");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to sign in: ${e.toString()}')),
                                  );
                                }
                              }),
                              signupOption(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row signupOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.black87),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpPage()),
            );
          },
          child: Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
