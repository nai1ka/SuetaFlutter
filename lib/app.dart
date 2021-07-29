import 'dart:async';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:test_flutter/ui/main/main_widget.dart';
import 'package:test_flutter/ui/registration/registration_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // add this line
  await Firebase.initializeApp(); // add this line
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {}
  }
  Future<bool> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isFirstTime = prefs.getBool('first_time');
    if (isFirstTime != null && !isFirstTime) {
      prefs.setBool('first_time', false);
      return false;
    } else {
      prefs.setBool('first_time', false);
      return true;
    }
  }
  Future<bool> isLogged() async{
    var user = FirebaseAuth.instance.currentUser;
    return user!=null;
  }

  @override
  Widget build(BuildContext context) {
    initializeFlutterFire();
    return FutureBuilder(
      // Replace the 3 second delay with your initialization code:
      future: isLogged(),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        if (snapshot.data==false) {
          return MaterialApp(
            builder: (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
            debugShowCheckedModeBanner: false,
            home: RegistrationWidget(),
          );
        } else {
          // Loading is done, return the app:
          return MaterialApp(
            builder: (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
            debugShowCheckedModeBanner: false,
            home: MainPage(),
          );
        }
      },
    );
  }


}



