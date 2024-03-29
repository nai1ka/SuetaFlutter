import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import 'package:test_flutter/core/Utils.dart';

import 'package:test_flutter/models/Event.dart';
import 'package:test_flutter/ui/eventInfo/event_info_widget.dart';

class EventListWidget extends StatefulWidget {
  const EventListWidget({Key? key}) : super(key: key);

  @override
  _EventListWidgetState createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('core')
                  .doc("events")
                  .collection("list")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                 return  FutureBuilder(
                    future: Utils.getEventsFromSnapshot(snapshot),
                    builder: (context, AsyncSnapshot<List<Event>> eventsSnap) {
                      var events = eventsSnap.data!;
                      return ListView.builder(
                          padding: EdgeInsets.all(8),
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
                                            EventInfoWidget(events[index].id)));
                              },
                              child: Card(
                                color: Color(0xFFFBF1A3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(25.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            events[index].eventName,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: 10.0)),
                                          Text(
                                              "${events[index].peopleNumber} человек"),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                              "${Utils.humanizeDate(events[index].eventDate)}"),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: 10.0)),
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EventInfoWidget(
                                                              events[index].id)));
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
                    },
                  );
                } else {
                  return Text("Нет мероприятий :(");
                }
              })),
    );
  }
}
