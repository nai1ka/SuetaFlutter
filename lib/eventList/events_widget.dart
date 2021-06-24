import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_flutter/models/Event.dart';

class EventListWidget extends StatefulWidget {
  const EventListWidget({Key? key}) : super(key: key);

  @override
  _EventListWidgetState createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventListWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('core')
                .doc("events")
                .collection("Kazan")
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              var events = getEvents(snapshot);
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: events.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 50,
                      color: Colors.amber[300],
                      child: Center(
                          child: Text('${events[index].eventName}')),
                    );
                  });
            }));
  }

  getEvents(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<Event> events = <Event>[];
    if (snapshot.hasData)
      snapshot.data!.docs.forEach((document) {
        GeoPoint tempGeoPoint =
            document["eventPosition"]["geopoint"] as GeoPoint;
        var tempEvent = Event()
          ..eventName = document["eventName"]
          ..eventPosition =
              LatLng(tempGeoPoint.latitude, tempGeoPoint.longitude)
          ..peopleNumber = document["peopleNumber"];
        events.add(tempEvent);
      });

    return events;
  }
}
