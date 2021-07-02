import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:test_flutter/models/Event.dart';
import 'package:test_flutter/ui/eventInfo/event_info_widget.dart';

class EventListWidget extends StatefulWidget {
  const EventListWidget({Key? key}) : super(key: key);

  @override
  _EventListWidgetState createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventListWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('core')
                  .doc("events")
                  .collection("Kazan")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                var events = getEvents(snapshot);
                return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: events.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26.0),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EventInfoWidget(events[index])));
                        },
                        child: Card(
                          color: Color(0xFFFBF1A3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(25.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      events[index].eventName,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 10.0)),
                                    Text(
                                        "${events[index].peopleNumber} человек"),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text("23 октября"),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 10.0)),
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EventInfoWidget(
                                                        events[index])));
                                      },
                                      child: Text("Join"),
                                      color: Color(0xFFB3DDC6),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              })),
    );
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
          ..peopleNumber = document["peopleNumber"]
          ..id = document.id;
        List<String> listOfUsers = [];
        Map<String,dynamic> tempUsers = document["users"];
        tempUsers.forEach((key, value) {
          listOfUsers.add(key);
        });
        tempEvent.users = listOfUsers;
        events.add(tempEvent);
      });

    return events;
  }
}
