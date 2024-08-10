import 'package:chat_application/Screens/Chat.dart';
import 'package:chat_application/Screens/Login.dart';
import 'package:chat_application/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor:
        Color.fromARGB(255, 56, 74, 80)),
        useMaterial3: true,
      ),
      // home: Login(),
      home : StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return Chat();
        } else {
          return const Login();
        }
      },),
      debugShowCheckedModeBanner: false,
    );
  }
}

