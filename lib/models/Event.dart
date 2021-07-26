import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_flutter/ui/main/main_widget.dart';


class Event {
  String? eventName;
  DateTime? eventDate;
  LatLng? eventPosition;
  int peopleNumber = 0;
  String? id;
  List<String> users = [];

  Future<void> saveToFirebase(BuildContext context, CollectionReference events) {
    // Call the user's CollectionReference to add a new user
    if (eventPosition == null || eventName == "")
      return Future(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Sending Message"),
        ));
      });
    return events
        .add({
          'eventDate': eventDate, // John Doe
          'eventName': eventName,
          'eventPosition': geo
              .point(
                  latitude: eventPosition!.latitude,
                  longitude: eventPosition!.longitude)
              .data, // Stokes and Sons
          'peopleNumber': 5,
      'users':{}// 42
        })
        .then((value) =>  Navigator.of(context, rootNavigator: true).pop())
        .catchError((error) => print("Failed to add user: $error"));
  }
}
