import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'auth_service.dart';
import 'todo_screen.dart';
import 'calendar_screen.dart'; // <- Jangan lupa buat file ini!
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

void addTodo() {
  FirebaseFirestore.instance.collection('todos').add({
    'task': 'Belajar Flutter Web',
    'done': false,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<String?>(
        future: AuthService().getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            return TodoScreen();
          } else {
            return SignInScreen();
          }
        },
      ),
      routes: {
        '/signin': (_) => SignInScreen(),
        '/signup': (_) => SignUpScreen(),
        '/todo': (_) => TodoScreen(),
        '/calendar': (_) => const CalendarScreen(),
      },
    );
  }
}