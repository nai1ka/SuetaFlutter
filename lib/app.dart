import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'main/main_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // add this line
  await Firebase.initializeApp(); // add this line
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  MyState createState() => MyState();
}

class MyState extends State<MyApp> {
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();

      setState(() {
        _initialized = true;
      });
    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

     return MaterialApp(
      title: 'Sueta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MainPage(),
    );
  }
}




