import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/models/Event.dart';

import 'package:test_flutter/ui/main/main_widget.dart';
import 'package:test_flutter/models/User.dart' as UserClass;

class Utils {
  static final Utils _singleton = Utils._internal();
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final firestore = FirebaseFirestore.instance;
  static final eventsReference = FirebaseFirestore.instance
      .collection('core')
      .doc("events")
      .collection("Kazan");
  static final userListReference = FirebaseFirestore.instance
      .collection("core")
      .doc("users")
      .collection("list");

  factory Utils() {
    return _singleton;
  }

  static Future<UserClass.User> getInfoAboutUser(String id) async {
    var rawUser = await firestore
        .collection("core")
        .doc("users")
        .collection("list")
        .doc(id)
        .get();
    if (rawUser.exists) {
      Map<String, dynamic> data = rawUser.data()!;
      var resultUser = UserClass.User(data["name"], data["age"], data["city"])
        ..friends = Map.castFrom(data["friends"])
        ..id = id;

      return resultUser;
    }
    throw "No such user";
    //TODO если пользоваель не существует(например, удалил аккаунт), то это сломается

    //var resultUser = User(rawUser.["name"], rawUser["name"], city, email)
  }

  static Future<List<UserClass.User>> getUsersFriendsProfiles(
      String userId) async {
    List<UserClass.User> resultList = [];
    Map<String, dynamic> friendsId = {};
    await FirebaseFirestore.instance
        .collection("core")
        .doc("users")
        .collection("list")
        .doc(userId)
        .get()
        .then((value) => friendsId = value.data()!["friends"]);
    for (var entry in friendsId.entries) {
      if (entry.value)
        await getInfoAboutUser(entry.key)
            .then((value) => resultList.add(value));
    }

    return resultList;
  }

  static Future<List<UserClass.User>> getUsersRequests(String userId) async {
    List<UserClass.User> resultList = [];
    List<dynamic> requestsId = [];
    await FirebaseFirestore.instance
        .collection("core")
        .doc("users")
        .collection("list")
        .doc(userId)
        .get()
        .then((value) => requestsId = value.data()!["friendRequests"]);
    for (var i in requestsId) {
      await getInfoAboutUser(i).then((value) => resultList.add(value));
    }

    return resultList;
  }

  static String humanizeDate(DateTime? date) {
    var resultString = "";
    if (date != null) {
      resultString += date.day.toString();
      switch (date.month) {
        case 1:
          resultString += " января";
          break;
        case 2:
          resultString += " февраля";
          break;
        case 3:
          resultString += " марта";
          break;
        case 4:
          resultString += " апреля";
          break;
        case 5:
          resultString += " мая";
          break;
        case 6:
          resultString += " июня";
          break;
        case 7:
          resultString += " июля";
          break;
        case 8:
          resultString += " августа";
          break;
        case 8:
          resultString += " сентября";
          break;
        case 8:
          resultString += " октября";
          break;
        case 8:
          resultString += " ноября";
          break;
        case 8:
          resultString += " декабря";
          break;
        default:
          resultString += "";
          break;
      }
      /*resultString+=" в ";
      resultString+=date.hour.toString();
      resultString+=":";
      resultString+=date.minute.toString();*/
    }
    return resultString;
  }

  static DateTime changeTime(DateTime dateTime, TimeOfDay timeOfDay) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, timeOfDay.hour,
        timeOfDay.minute);
  }

  static String formatDate(DateTime dateTime) {
    return "${dateTime.year} - ${dateTime.month} - ${dateTime.day}";
  }

  static checkEvent(Event event) {
    return event.eventName.length > 0 &&
        event.eventDescription.length > 0 &&
        event.peopleNumber > 0 &&
        event.eventPosition != null;
  }

  static saveEventToFirebase(Event event) {
    eventsReference.add({
      'eventDate': event.eventDate,
      'eventName': event.eventName,
      'eventDescription': event.eventDescription,
      'eventOwner': event.eventOwnerId,
      'eventPosition': geo
          .point(
              latitude: event.eventPosition!.latitude,
              longitude: event.eventPosition!.longitude)
          .data,
      'peopleNumber': event.peopleNumber,
      'users': {}
    }).then((value) =>
        userListReference.doc(auth.currentUser!.uid).update({"events": [value.id]}));
  }

//var resultUser = User(rawUser.["name"], rawUser["name"], city, email)

  Utils._internal();
}
