import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_flutter/core/Utils.dart';
import 'package:test_flutter/models/Event.dart';
import 'package:test_flutter/models/EventDescription.dart';
import 'package:test_flutter/ui/eventInfo/guests_info.dart';
import 'package:test_flutter/ui/profile/user_profile.dart';

final firebase = FirebaseFirestore.instance
    .collection('core')
    .doc("events")
    .collection("list");
final FirebaseAuth auth = FirebaseAuth.instance;
Completer<GoogleMapController> _controller = Completer();

class EventInfoWidget extends StatefulWidget {
  EventInfoWidget(this.eventId);

  String eventId = "";

  @override
  _EventInfoWidgetState createState() => _EventInfoWidgetState();
}

class _EventInfoWidgetState extends State<EventInfoWidget> {
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/mapStyle.json').then((string) {
      _mapStyle = string;
    });
  }

  int isButtonClicked = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Utils.getEventDescription(widget.eventId),
        builder: (BuildContext context,
            AsyncSnapshot<EventDescription> eventSnapshot) {
          if (eventSnapshot.connectionState == ConnectionState.none ||
              !eventSnapshot.hasData) {
            //print('project snapshot data is: ${projectSnap.data}');
            return Container();
          }
          var event = eventSnapshot.data!.event!;
          var user = eventSnapshot.data!.user!;
          //TODO здесь event или user могут быть null, если возникла ошибка при их получении => обработать исключение
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.amber,

              title: event.isCurrentUserOwner ?Row(
                mainAxisAlignment: MainAxisAlignment.end,

                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>GuestInfoWidget(event.id)));
                      },
                      icon: Icon(Icons.supervised_user_circle_outlined)),
                ],
              ) : null,
            ),
            bottomNavigationBar: getConfirmButton(event),
            //TODO сделать статус для гостя (принята заявка, отклонена или на рассмотрении)
            body: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.eventName,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                            Text(Utils.getDateForDescription(event.eventDate, event.isAccepted|event.isCurrentUserOwner))
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
                            "Ещё не хватает ${event.peopleNumber - event.users.length} гостей"),
                        Divider(
                          thickness: 2,
                          height: 16,
                        ),
                        Text(
                          "Описание",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 8)),
                        Text(event.eventDescription),
                        Padding(padding: EdgeInsets.only(bottom: 8)),
                        Text(
                          "Проводит:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 8)),
                        InkWell(
                          onTap: () {
                            if (user.id != auth.currentUser!.uid)
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UserProfile(user.id)));
                            else {
                              Fluttertoast.showToast(
                                  msg: "Это же вы :)",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  fontSize: 16.0);
                            }
                          },
                          child: Container(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  child: Icon(Icons.supervised_user_circle),
                                ),
                                Padding(padding: EdgeInsets.only(right: 6)),
                                Text(
                                  user.name,
                                  style: TextStyle(fontSize: 16),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 8)),
                        Text(
                          "Местоположение",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                                    markerId: MarkerId(event.id),
                                    position: event.eventPosition!)
                              ]),
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                    37.42796133580664, -122.085749655962),
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
        });
  }

  getConfirmButton(Event event) {
    var isClickable = !Utils.checkIfUserAlreadyRegisteredInEvent(event);
    if (isClickable) {
      return Container(
        width: double.infinity,
        height: 100,
        padding: EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: () {
            var status = Utils.addUserAsGuest(event.id);
            if (status) {
              CoolAlert.show(
                  context: context,
                  type: CoolAlertType.success,
                  title: 'Вы успешно записались на мероприятие!',
                  autoCloseDuration: Duration(seconds: 2),
                  confirmBtnText: "Ура!",
                  confirmBtnColor: Colors.lightGreen,
                  onConfirmBtnTap: () {
                    Navigator.pop(context);
                  }).then((value) => Navigator.pop(context));
            } else {
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
      );
    } else {
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
