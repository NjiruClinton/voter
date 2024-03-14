import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../auth.dart';
import 'home.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  // text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  // send login request to 127.0.0.1:8000/login

  // var url = Uri.parse('https://8d28-102-219-208-154.ngrok-free.app/login');
  //
  // Future<http.Response> _submit() async {
  //   var response = await http.post(url, body: {
  //     'username': _emailController.text,
  //     'password': _passwordController.text
  //   });
  //
  //   if (response.statusCode == 200) {
  //     //   navigate to home page
  //     Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  //   } else {
  //     //   show error message
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Invalid email or password'),
  //       backgroundColor: Colors.red,
  //     ));
  //   }
  //
  //   return http.post(
  //     Uri.parse('https://8d28-102-219-208-154.ngrok-free.app/login/'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'username': _emailController.text,
  //       'password': _passwordController.text,
  //     }),
  //
  //   );
  //
  // }

  String? errorMessage = '';

  Future<void> signUserIn() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        print(e.code);
        errorMessage = e.message;
      });
    }
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == "" ? "" : 'Humm ? $errorMessage',
      style: const TextStyle(color: Colors.redAccent),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Enter your email to reset your password'),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: "Email",
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Send'),
              onPressed: () {
                // send reset password email
                Auth().sendPasswordResetEmail(email: _emailController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Welcome back", style: GoogleFonts.roboto(fontSize: 35, fontWeight: FontWeight.bold),),
          //   logo and 2 inputs and a button
            Image.asset('assets/images/voting-logo.jpg'),
            SizedBox(height: 20),
          _errorMessage(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
                controller: _emailController,
                obscureText: false,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade400),
                  ),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                )
            ),
          ),

          SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade400),
                  ),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                )
            ),
          ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text("Forgot password?",
                        style: TextStyle(color: Colors.grey.shade600)),
                    onPressed: () {
                      _showMyDialog();
                    },
                  ),
                ],
              ),
            ),

        SizedBox(height: 20),

        GestureDetector(
          onTap: () {
            signUserIn();
          },
          child: Container(
              padding: EdgeInsets.all(25),
              margin: EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(color: Colors.black,
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text(
                    "Sign In",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  )
              )
          ),
        )


          ],
        ),
      )
    );
  }
}
