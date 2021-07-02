import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/models/User.dart';

class Utils {
  static final Utils _singleton = Utils._internal();
  static final firestore = FirebaseFirestore.instance;

  factory Utils() {
    return _singleton;
  }

  static Future<User> getInfoAboutUser(String id) async {
    var rawUser = await firestore.collection("core").doc("users").collection(
        "list").doc(id).get();
    if (rawUser.exists) {
      Map<String, dynamic> data = rawUser.data()!;
      var resultUser = User(data["name"], data["age"], data["city"])
        ..friends = List.castFrom(data["friends"]);

      return resultUser;
    }
    throw "No such user";
    //TODO если пользоваель не существует(например, удалил аккаунт), то это сломается

    //var resultUser = User(rawUser.["name"], rawUser["name"], city, email)
  }

  static Future<List<User>> getUsersFriendsProfiles(
      List<dynamic> friendsId) async {
    List<User> resultList = [];
    for (int i = 0; i < friendsId.length; i++) {
      await getInfoAboutUser(friendsId[i]).then((value) =>
          resultList.add(value));
    }

    return resultList;
  }


//var resultUser = User(rawUser.["name"], rawUser["name"], city, email)


  Utils._internal();
}