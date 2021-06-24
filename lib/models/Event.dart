import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_flutter/dialogs/AddEventDialog.dart';

class Event {
  String? eventName;
  DateTime? eventDate;
  LatLng? eventPosition;
  int? peopleNumber;

  Future<void> addToFirebase(BuildContext context, CollectionReference users) {
    // Call the user's CollectionReference to add a new user
    print(eventName);
    if (eventPosition == null || eventName == "")
      return Future(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Sending Message"),
        ));
      });
    return users
        .add({
          'eventDate': eventDate, // John Doe
          'eventName': eventName,
          'eventPosition': geo
              .point(
                  latitude: eventPosition!.latitude,
                  longitude: eventPosition!.longitude)
              .data, // Stokes and Sons
          'eventTime': "4:20",
          'peopleNumber': 5 // 42
        })
        .then((value) =>  Navigator.of(context, rootNavigator: true).pop())
        .catchError((error) => print("Failed to add user: $error"));
  }
}
