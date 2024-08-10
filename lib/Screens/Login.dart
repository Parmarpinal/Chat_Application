import 'dart:io';

import 'package:chat_application/Model/user_profile.dart';
import 'package:chat_application/Services/database_service.dart';
import 'package:chat_application/Widgets/UserImagePicker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  File? image;
  GlobalKey<FormState> userform = GlobalKey();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();
  bool isLogin = true;
  bool isAuthenticating = false;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DatabaseService _databaseService = DatabaseService();


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (userform.currentState!.validate()) {
      isAuthenticating = true;
      try {
        final FirebaseAuth _firebase = FirebaseAuth.instance;
        UserCredential userCredential;

        if (!isLogin && image == null) {
          return;
        }

        if (isLogin) {
          userCredential = await _firebase.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
        } else {
          if (image == null) {
            return;
          }

          userCredential = await _firebase.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );

          try {
            final fileName = 'images/${userCredential.user!.uid}.png';
            final ref = _storage.ref().child(fileName);
            await ref.putFile(image!);

            final downloadUrl = await ref.getDownloadURL();
            print('File uploaded successfully. URL: $downloadUrl');

            if (downloadUrl != null) {
              await _databaseService.createUserProfile(
                  user: UserProfile(
                      uid: userCredential.user!.uid,
                      name: nameController.text,
                      imgUrl: downloadUrl)
              );
            }
          } catch (e) {
            print('Error occurred while uploading image: $e');
          }
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication failed')),
        );
      }
      setState(() {
        isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Color.fromARGB(255, 56, 74, 80),
                    Color.fromARGB(255, 79, 168, 162),
                    Color.fromARGB(255, 121, 173, 169),
                    Color.fromARGB(100, 168, 236, 215),
                  ], begin: Alignment.topRight, end: Alignment.bottomLeft),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 30, bottom: 30),
                          child: Text(isLogin ? "Login" : "Sign up",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.7,
                    decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(40))),
                    child: Padding(
                      padding: EdgeInsets.only(left: 25, top: 25),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(40))),
                        child: Form(
                          key: userform,
                          child: Padding(
                            padding: EdgeInsets.only(top: 30,
                                right: 15,
                                left: 15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (!isLogin)
                                  UserImagePicker(onPickImage: (i) {
                                    setState(() {
                                      image = i;
                                    });
                                  }),
                                if (!isLogin)
                                  TextFormField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                        labelText: "Name",
                                        labelStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 56, 74, 80),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 22,
                                        )),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Enter Name";
                                      }
                                      if (value.length > 50) {
                                        return "Enter your name";
                                      }
                                    },
                                  ),
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                      labelText: "Email",
                                      labelStyle: TextStyle(
                                        color: Color.fromARGB(255, 56, 74, 80),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22,
                                      )),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter email";
                                    }
                                    if (!EmailValidator.validate(value)) {
                                      return "Enter correct email address";
                                    }
                                  },
                                ),
                                TextFormField(
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                      labelText: "Password",
                                      labelStyle: TextStyle(
                                        color: Color.fromARGB(255, 56, 74, 80),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22,
                                      )),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter password";
                                    }
                                    if (value.length < 6 || value.length > 10) {
                                      return "Password length should be between 6 to 10";
                                    }
                                  },
                                ),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          isLogin = !isLogin;
                                        });
                                      },
                                      child: Text(
                                        isLogin
                                            ? "Create new account"
                                            : "Already have an account",
                                        style: TextStyle(
                                            fontSize: 19,
                                            color:
                                            Color.fromARGB(255, 79, 168, 162),
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (isAuthenticating)
                                      CircularProgressIndicator(),
                                    if (!isAuthenticating)
                                      InkWell(
                                        onTap: submit,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                            color: Color.fromARGB(
                                                255, 56, 74, 80),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(11),
                                            child: Text(
                                              isLogin ? "Sign in" : "Sign up",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
