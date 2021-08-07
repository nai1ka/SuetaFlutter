import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:im_stepper/stepper.dart';

import 'package:test_flutter/core/Utils.dart';
import 'package:test_flutter/models/Event.dart';

CollectionReference events = FirebaseFirestore.instance
    .collection('core')
    .doc("events")
    .collection("list");
final FirebaseAuth auth = FirebaseAuth.instance;
Event newEvent = Event()..eventOwnerId = auth.currentUser!.uid;
List markers = [];
String? _mapStyle;

class EventAddWidget extends StatefulWidget {
  const EventAddWidget({Key? key}) : super(key: key);

  @override
  _EventAddWidgetState createState() => _EventAddWidgetState();
}

class _EventAddWidgetState extends State<EventAddWidget> {
  int activeStep = 0; // Initial step set to 5.

  @override
  void initState() {
    markers = [];
    newEvent = Event()..eventOwnerId = auth.currentUser!.uid;
    rootBundle.loadString('assets/mapStyle.json').then((string) {
      _mapStyle = string;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
          leading: BackButton(onPressed: () => Navigator.pop(context, true))),*/
      body: SafeArea(
        child: Column(
          children: [
            IconStepper(
              icons: [
                Icon(Icons.description_outlined),
                Icon(Icons.map),
              ],
              enableNextPreviousButtons: false,
              stepColor: Colors.white,
              // activeStep property set to activeStep variable defined above.
              activeStep: activeStep,

              // This ensures step-tapping updates the activeStep.
              onStepReached: (index) {
                setState(() {
                  activeStep = index;
                });
              },
            ),

            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: getWidget(activeStep),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget descriptionWidget() {
    return Scaffold(
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
             Navigator.pop(context);
            },
            child: Text(
              "Выход",
              style: TextStyle(color: Color(0xFF2A41CB), fontSize: 15),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                activeStep++;
              });
            },
            child: Text(
              "Далее",
              style: TextStyle(color: Color(0xFF2A41CB), fontSize: 15),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Введите название:",
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF2A41CB),
                  fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              initialValue: newEvent.eventName,
              textInputAction: TextInputAction.next,
              decoration: new InputDecoration(
                  border: OutlineInputBorder(), labelText: "Название"),
              onChanged: (text) {
                newEvent.eventName = text;
              },
            ),
            Padding(padding: EdgeInsets.all(10)),
            Text(
              "Введите описание:",
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF2A41CB),
                  fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              initialValue: newEvent.eventDescription,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.next,
              maxLines: null,
              decoration: new InputDecoration(
                  border: OutlineInputBorder(), labelText: "Описание"),
              onChanged: (text) {
                newEvent.eventDescription = text;
              },
            ),
            Padding(padding: EdgeInsets.all(10)),
            Text(
              "Сколько ещё человек нужно?",
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF2A41CB),
                  fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.all(5)),
            TextFormField(
              initialValue: newEvent.peopleNumber == 0
                  ? ""
                  : newEvent.peopleNumber.toString(),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLines: null,
              decoration: new InputDecoration(
                  border: OutlineInputBorder(), labelText: "Количество людей"),
              onChanged: (number) {
                newEvent.peopleNumber = int.tryParse(number) ?? 0;
              },
            ),
            Padding(padding: EdgeInsets.all(10)),
            Text(
              "Выберите дату проведения:",
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF2A41CB),
                  fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.all(5)),
            ElevatedButton(
              onPressed: () {
                selectDate(context);
              },
              child: Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(Icons.calendar_today_outlined),
                    Padding(padding: EdgeInsets.only(right: 8)),
                    Text(Utils.formatDate(newEvent.eventDate)),
                    Spacer(),
                    Text("Изменить")
                  ],
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(10)),
            Text(
              "Выберите время проведения:",
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF2A41CB),
                  fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.all(5)),
            ElevatedButton(
              onPressed: () {
                selectTime(context);
              },
              child: Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(Icons.watch_later_outlined),
                    Padding(padding: EdgeInsets.only(right: 8)),
                    Text(
                        "${newEvent.eventDate.hour}:${newEvent.eventDate.minute}"),
                    Spacer(),
                    Text("Изменить")
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*Widget MapWidget(){
    return Container(
      child: Column(
        children: [
          TextFormField(
            onChanged: (text){},
          )
        ],
      ),
    );
  }*/
  Widget mapWidget() {
    Completer<GoogleMapController> _controller = Completer();
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height - 250,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            markers: Set.from(markers),
            onTap: onMapTap,
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
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  activeStep--;
                });
              },
              child: Text(
                "Назад",
                style: TextStyle(color: Color(0xFF2A41CB), fontSize: 15),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (Utils.checkEvent(newEvent)) {
                    Utils.saveEventToFirebase(newEvent);
                    Navigator.pop(context, true);
                  } else {
                    Fluttertoast.showToast(
                      msg: "Неверно введены данные",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                });
              },
              child: Text(
                "Готово",
                style: TextStyle(color: Color(0xFF2A41CB), fontSize: 15),
              ),
            )
          ],
        )
      ],
    );
  }

  onMapTap(LatLng point) {
    setState(() {
      newEvent.eventPosition = point;

      var tempMarker = Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );

      if (markers.isNotEmpty)
        markers[0] = tempMarker;
      else
        markers.add(tempMarker);
    });
  }

  selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: newEvent.eventDate,
        lastDate: DateTime(DateTime.now().year + 1),
        firstDate: DateTime(DateTime.now().year));
    if (picked != null && picked != newEvent.eventDate)
      setState(() {
        newEvent.eventDate = picked;
      });
  }

  selectTime(BuildContext context) async {
    var now = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        newEvent.eventDate = Utils.changeTime(newEvent.eventDate, selectedTime);
      });
  }

  Widget getWidget(int index) {
    Widget resultWidget = descriptionWidget();
    switch (index) {
      case 0:
        resultWidget = descriptionWidget();
        break;
      case 1:
        resultWidget = mapWidget();
        break;
    }
    return resultWidget;
  }
}
