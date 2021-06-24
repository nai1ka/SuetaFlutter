import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_flutter/models/Event.dart';

final geo = Geoflutterfire();

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({Key? key}) : super(key: key);

  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  DateTime selectedDate = DateTime.now();
  String eventName = "";
  LatLng? selectedPosition;
  List markers = [];
  Event newEvent = Event();

  CollectionReference users = FirebaseFirestore.instance
      .collection('core')
      .doc("events")
      .collection("Kazan");

  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    Completer<GoogleMapController> _controller = Completer();
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "1. Введите название события:",
                textAlign: TextAlign.left,
              ),
              TextField(

                decoration: InputDecoration(hintText: "Название"),
                onSubmitted: (text) {
                  newEvent.eventName = text;
                },
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              Text("2. Выберите место события:"),
              Container(
                width: 300,
                height: 300,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GoogleMap(
                    markers: Set.from(markers),
                    mapType: MapType.hybrid,
                    onTap: onMapTap,

                    initialCameraPosition: CameraPosition(
                      target: LatLng(37.42796133580664, -122.085749655962),
                      zoom: 14.4746,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              Text("3. Выберите время:"),
              MaterialButton(
                  color: Colors.amber,
                  child: Text("Выбрать"),
                  onPressed: () {
                    selectDate(context);
                  }),
              Spacer(),
              MaterialButton(
                  color: Colors.lightGreen,
                  child: Text("Закончить"),
                  onPressed: () {
                     newEvent.addToFirebase(context, users);

                  }),
            ],
          ),
        ));
  }

  selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2021), // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != newEvent.eventDate)
      setState(() {
        newEvent.eventDate = picked;
      });
  }

  onMapTap(LatLng point) {
    setState(() {
     newEvent.eventPosition = point;

      var tempMarker = Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(
          title: 'I am a marker',
        ),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );

      if (markers.isNotEmpty)
        markers[0] = tempMarker;
      else
        markers.add(tempMarker);
    });
  }


}
