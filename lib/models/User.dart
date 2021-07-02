

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class User{
  String name = "";
  int age = 0;
  String city = "Казань";
  String email = "";
  String id = "";
  List<String> friends = [];


  User(this.name, this.age, this.city);



}