import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_flutter/core/Utils.dart';
import 'package:test_flutter/models/Event.dart';

final firebase = FirebaseFirestore.instance
    .collection('core')
    .doc("events")
    .collection("list");
final FirebaseAuth auth = FirebaseAuth.instance;
Completer<GoogleMapController> _controller = Completer();

class EventInfoWidget extends StatefulWidget {
  EventInfoWidget(this.event);

  Event? event;

  @override
  _EventInfoWidgetState createState() => _EventInfoWidgetState();
}

class _EventInfoWidgetState extends State<EventInfoWidget> {
  Event? event = null;
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    event = widget.event;
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  int isButtonClicked = 0;

  @override
  Widget build(BuildContext context) {
    if (event != null) {
      return Scaffold(
        bottomNavigationBar: getConfirmButton(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event!.eventName,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 10)),
                    Row(
                      children: [
                        Icon(
                          Icons.watch_later_outlined,
                          size: 16,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(Utils.getDateForDescription(event!.eventDate))
                      ],
                    ),
                    /*Row(
                children: [
                  Icon(Icons.location_on_outlined),
                  Text(Utils.getDateForDescription(event!.eventDate))
                ],
              )*/
                    Padding(padding: EdgeInsets.only(bottom: 10)),
                    Text(
                        "Ещё не хватает ${event!.peopleNumber - event!.users.length} гостей"),
                    Divider(
                      thickness: 2,
                      height: 16,
                    ),
                    Text(
                      "Описание",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 8)),
                    Text(event!.eventDescription),
                    Padding(padding: EdgeInsets.only(bottom: 8)),
                    Text(
                      "Проводит:",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    //TODO добавить ссылку на пользователя, который проводит
                    Text(
                      "Местоположение",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 10)),
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        child: GoogleMap(
                          markers: Set.from([
                            Marker(
                                markerId: MarkerId(event!.id),
                                position: event!.eventPosition!)
                          ]),
                          initialCameraPosition: CameraPosition(
                            target: LatLng(37.42796133580664, -122.085749655962),
                            zoom: 14.4746,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                            controller.setMapStyle(_mapStyle);
                          },
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      );
    } else {
      return Text("Ошибка");
    }
  }

  getConfirmButton(){
    var isClickable = true;
    if(Utils.checkIfUserAlreadyRegisteredInEvent(event!)) isClickable = false;
    if(isClickable){
    return Container(
      width: double.infinity,
      height: 100,
      padding: EdgeInsets.all(20.0),
      child: ElevatedButton(

        onPressed: () {
          var status = Utils.addUserAsGuest(widget.event!.id);
          if(status) {
            CoolAlert.show(
                context: context,
                type: CoolAlertType.success,
                title: 'Вы успешно записались на мероприятие!',
                autoCloseDuration: Duration(seconds: 2),
                confirmBtnText: "Ура!",
                confirmBtnColor: Colors.lightGreen,
                onConfirmBtnTap: (){
                  Navigator.pop(context);
                }
            ).then((value) =>  Navigator.pop(context));
          }
          else {
            CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              title: 'Упс...',
              text: 'Что-то пошло не так, обратитесь к разработчику',
              loopAnimation: false,
              autoCloseDuration: Duration(seconds: 2),
            );
          }
          setState(() {
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
    );}
    else{
      return Container(
        width: double.infinity,
        height: 100,
        padding: EdgeInsets.all(20.0),
        child: ElevatedButton(

          onPressed: null,
          child: Text("Вы уже записаны!"),
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ))),
        ),
      );
    }

  }
}
