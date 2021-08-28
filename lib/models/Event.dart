
import 'package:google_maps_flutter/google_maps_flutter.dart';


class Event {
  String eventName = "";
  String eventDescription = "";
  DateTime eventDate = DateTime.now();
  String eventOwnerId = "";
  LatLng? eventPosition;
  int peopleNumber = 0;
  String id = "";
  Map<String,bool> users = {};
  bool isCurrentUserOwner = false;
  bool isAccepted = false;
  List<String> imageURLs = [];





}
