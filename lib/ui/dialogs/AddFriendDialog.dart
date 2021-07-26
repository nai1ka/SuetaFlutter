import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_flutter/models/Event.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

class AddFriendDialog extends StatefulWidget {
  const AddFriendDialog({Key? key}) : super(key: key);

  @override
  _AddFriendDialogState createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  String? friendId;

  CollectionReference users = FirebaseFirestore.instance
      .collection('core')
      .doc("users")
      .collection("list");

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Введите ID друга:",
                textAlign: TextAlign.center,
              ),
              TextFormField(
                decoration: InputDecoration(hintText: "ID"),
                onChanged: (text) {
                    friendId = text;
                },
              ),
              Padding(padding: EdgeInsets.all(5.0)),
              Text(
                "Ваш ID:",
                style: TextStyle(color: Colors.white24),
              ),
              Container(
                width: double.infinity,
                height: 60,
                padding: EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () {

                    //TODO сделать проверку на действительность id и то что friendId!=currentUserId
                    users.doc(auth.currentUser!.uid).update({
                      "friends": {friendId: false}
                    });
                    users.doc(friendId).update({
                    "friendRequests":
                    FieldValue.arrayUnion([auth.currentUser!.uid])
                    });
                  },
                  child: Text("Отправить запрос"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return Colors.lightGreen;
                        },
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ))),
                ),
              )
            ],
          ),
        ));
  }
}
