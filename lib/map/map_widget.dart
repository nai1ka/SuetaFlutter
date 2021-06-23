import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_flutter/dialogs/AddEventDialog.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('core')
                .doc("events")
                .collection("Kazan").snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return GoogleMap(
                mapType: MapType.hybrid,
                initialCameraPosition: _kGooglePlex,
                markers:Set<Marker>.of(getEventsMarker(snapshot)),
                padding: EdgeInsets.fromLTRB(0, 0, 0, 60) +
                    MediaQuery
                        .of(context)
                        .padding,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              );
            }));
  }



  getEventsMarker(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<Marker> markers = <Marker>[];
    if (snapshot.hasData)
      snapshot.data!.docs.forEach((document) {
        GeoPoint tempGeoPoint = document["eventPosition"]["geopoint"] as GeoPoint;
        markers.add(
            Marker(
                markerId: MarkerId(document.id),
                position: LatLng(tempGeoPoint.latitude, tempGeoPoint.longitude),
                infoWindow: InfoWindow(
                  title: document["eventName"],
                )
            )
        );
      });
    print(markers);
    var t = Set<Marker>.of(markers);
    return markers;

  }

}
