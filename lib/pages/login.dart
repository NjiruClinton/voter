import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? errorMessage = '';

  Future<void> signUserIn() async {

    try {
      final authResult = await Auth().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final user = authResult;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Email Verification Required'),
              content: Text('A verification email has been sent to ${user.email}. Please verify your email before signing in.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }

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
        ),

          //   or create account
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ", style: TextStyle(color: Colors.grey.shade600),),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                  child: Text("Register as a student", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}


class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();


  String? errorMessage = '';

  Future<void> signUserUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Auth().createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        await FirebaseFirestore.instance.collection('students').add({
          'email': _emailController.text,
          'name': _nameController.text,
          'last_name': _lastNameController.text,
          'studentId': _studentIdController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'pending'
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered successfully')),
        );
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _nameController.clear();
        _lastNameController.clear();
        _studentIdController.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          print(e.code);
          errorMessage = e.message;
        });
      }
    }
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == "" ? "" : 'Humm ? $errorMessage',
      style: const TextStyle(color: Colors.redAccent),
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
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextFormField(
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
                          ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Email';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextFormField(
                        controller: _nameController,
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
                          hintText: "First name",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextFormField(
                        controller: _lastNameController,
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
                          hintText: "Last name",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextFormField(
                        controller: _studentIdController,
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
                          hintText: "Student ID",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your student ID';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextFormField(
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextFormField(
                        controller: _confirmPasswordController,
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
                          hintText: "Confirm Password",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        ),
                        validator: (value) {
                          if(value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          } else if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );
                          signUserUp();
                        }
                      },
                      child: Container(
                          padding: EdgeInsets.all(25),
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          decoration: BoxDecoration(color: Colors.black,
                              borderRadius: BorderRadius.circular(8)),
                          child: Center(
                              child: Text(
                                "Register",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              )
                          )
                      ),
                    ),
                  ],
                ),
              ),


              //   or create account
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Have an account? ", style: TextStyle(color: Colors.grey.shade600),),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: Text("Sign in now", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                  ),
                ],
              ),


            ],
          ),
        )
    );
  }
}
