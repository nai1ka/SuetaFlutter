import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/models/Event.dart';

final firebase = FirebaseFirestore.instance
    .collection('core')
    .doc("events")
    .collection("Kazan");
final FirebaseAuth auth = FirebaseAuth.instance;

class EventInfoWidget extends StatefulWidget {
  EventInfoWidget(this.event);
  Event? event;


  @override
  _EventInfoWidgetState createState() => _EventInfoWidgetState();
}

class _EventInfoWidgetState extends State<EventInfoWidget> {
  int isButtonClicked = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          AspectRatio(
              aspectRatio: 4 / 3,
              child: new Container(
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.only(
                      bottomLeft: const Radius.circular(40.0),
                      bottomRight: const Radius.circular(40.0),
                    ),
                    image: new DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: FractionalOffset.topCenter,
                      image: new NetworkImage(
                          'https://im0-tub-ru.yandex.net/i?id=eb4ca19b1b2be7b8df5beba041c28c6f-l&n=13'),
                    )),
              )),
          Padding(padding: EdgeInsets.only(bottom: 40.0)),
          Container(
              padding: EdgeInsets.all(20.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "${widget.event!.eventName}",
                        style: TextStyle(
                            fontSize: 40,
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold),
                        softWrap: true,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      decoration: new BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: new BorderRadius.all(Radius.circular(10)),
                        border: new Border.all(
                          color: Color(0xFF8E8E8E),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text("Ещё ${widget.event!.peopleNumber - widget.event!.users.length-isButtonClicked} человек"),
                          Padding(padding: EdgeInsets.only(right: 4.0)),
                          Icon(Icons.people),
                        ],
                      ),
                    ),
                  ])),
          Spacer(),
          Container(
            width: double.infinity,
            height: 100,
            padding: EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {


                firebase.doc(widget.event!.id).set({
                  "users": {auth.currentUser?.uid: true}
                }, SetOptions(merge: true));
                setState((){
                  isButtonClicked = 1;
                });
              },
              child: Text("Я буду!"),
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ))),
            ),
          )
        ]),
      ),
    );
  }
}
