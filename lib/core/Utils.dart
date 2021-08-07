import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_flutter/models/CustomError.dart';
import 'package:test_flutter/models/Event.dart';
import 'package:test_flutter/models/EventDescription.dart';

import 'package:test_flutter/ui/main/main_widget.dart';
import 'package:test_flutter/models/User.dart' as UserClass;

class Utils {
  static final Utils _singleton = Utils._internal();
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final firestore = FirebaseFirestore.instance;
  static final storage =
      FirebaseStorage.instance;
  static final eventsReference = FirebaseFirestore.instance
      .collection('core')
      .doc("events")
      .collection("list");
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
      await getAvatarsURL(id).then((value) =>
      resultUser.avatarURL =  value);
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

   static Future<List<Event>> getEventsFromSnapshot(AsyncSnapshot<QuerySnapshot> snapshot) async{
    List<Event> events = <Event>[];
    if (snapshot.hasData)
      for (int i = 0; i < snapshot.data!.docs.length; i++) {
        await getInfoAboutEvent(snapshot.data!.docs[i].id).then((value) =>
            events.add(value));
      }
    return events;
  }

  static Future<Event> getInfoAboutEvent(String id) async {
    var rawEvent = await firestore
        .collection("core")
        .doc("events")
        .collection("list")
        .doc(id)
        .get();
    if (rawEvent.exists) {
      var data = rawEvent.data()!;
      GeoPoint tempGeoPoint =
      data["eventPosition"]["geopoint"] as GeoPoint;
      var resultEvent = Event()..eventName = data["eventName"]
      ..eventDescription = data["eventDescription"]
        ..eventPosition =
        LatLng(tempGeoPoint.latitude, tempGeoPoint.longitude)
        ..eventDate = (data["eventDate"] as Timestamp).toDate()
      ..eventOwnerId = data["eventOwner"]
      ..peopleNumber = data["peopleNumber"]
      ..id = id
      ..users = List.castFrom(data["users"]);


      return resultEvent;
    }
    throw "Нет";
    //TODO если событие не существует(например, удалил аккаунт), то это сломается

    //var resultUser = User(rawUser.["name"], rawUser["name"], city, email)
  }

  static Future<List<Event>> getUsersOwnEvents(String userId) async {
    List<Event> resultList = [];
    Map<String,dynamic> requestsId = {};
    await FirebaseFirestore.instance
        .collection("core")
        .doc("users")
        .collection("list")
        .doc(userId)
        .get()
        .then((value) => requestsId = value.data()!["events"]);
    for (var i in requestsId.entries) {
      if(i.value == true) await getInfoAboutEvent(i.key).then((value) => resultList.add(value));
    }
    return resultList;
  }

  static Future<List<Event>> getUsersAvailableEvents(String userId) async {
    List<Event> resultList = [];
    Map<String,dynamic> requestsId = {};
    await FirebaseFirestore.instance
        .collection("core")
        .doc("users")
        .collection("list")
        .doc(userId)
        .get()
        .then((value) => requestsId = value.data()!["events"]);
    for (var i in requestsId.entries) {
      if(i.value == false) await getInfoAboutEvent(i.key).then((value) => resultList.add(value));
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
        case 9:
          resultString += " сентября";
          break;
        case 10:
          resultString += " октября";
          break;
        case 11:
          resultString += " ноября";
          break;
        case 12:
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
  static getDateForDescription(DateTime date){
    return "${humanizeDate(date)}, ${date.year} | ${date.hour}:${date.minute}";

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
      'users': []
    }).then((value) =>
        userListReference.doc(auth.currentUser!.uid).update({"events": {value.id:true}
        }));
  }

  static deleteEvent(Event event){
    try{
      eventsReference.doc(event.id).delete();
      event.users.forEach((element) {
        userListReference.doc(element).update({
          "events.${event.id}":
          FieldValue.delete()
        });

      });
      userListReference.doc(event.eventOwnerId).update({
        "events.${event.id}":
        FieldValue.delete()
      });
      return true;
    }
    catch(e){
      return false;
    }

  }

  static addUserAsGuest(String eventID){
    try {
      eventsReference.doc(eventID).set({
        "users": [auth.currentUser?.uid]
      }, SetOptions(merge: true));
      //Добавление данных в field users в документе events
      userListReference.doc(auth.currentUser!.uid).update(
          {"events": {eventID: false}});
      //Добавление данных в field events в документе users (false, потому что гость - пользователь)
      return true;
    }
    catch (e) {
      return false;
    }
  }

  static bool checkIfUserAlreadyRegisteredInEvent(Event event){
    return event.users.contains(auth.currentUser!.uid) || event.eventOwnerId==auth.currentUser!.uid;
  }
  static Future<EventDescription> getEventDescription(String eventId) async{
    var event = await getInfoAboutEvent(eventId);
    var user = await getInfoAboutUser(event.eventOwnerId);

    return EventDescription(event,user);

  }

  static Future<MethodResponse> sendFriendsRequest(String friendId) async{
    try {
     var currentUser =  await getInfoAboutUser(auth.currentUser!.uid);
     if(currentUser.friends.containsKey(friendId)) return MethodResponse(true,"Этот пользователь уже у вас в друзьях");
      userListReference.doc(auth.currentUser!.uid).update({
        "friends": {friendId: false}
      });
      userListReference.doc(friendId).update({
        "friendRequests":
        FieldValue.arrayUnion([auth.currentUser!.uid])
      });
      return MethodResponse(false);
    }
    catch (e){
      return MethodResponse(true,e.toString());
    }
  }
  static changeAvatarImage(File file) async{
    try {
      await storage
          .ref('avatars/${auth.currentUser!.uid}.png')
          .putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  static Future<String> getAvatarsURL(String userId) async{
    var downloadURL = "";
    try{
      downloadURL = await storage
          .ref('avatars/${userId}.png')
          .getDownloadURL();
    }
    catch(e){

    }
    return downloadURL;

  }

//var resultUser = User(rawUser.["name"], rawUser["name"], city, email)

  Utils._internal();
}
