import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  String? _mapStyle;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

 @override
  void initState() {
   rootBundle.loadString('assets/map_style.txt').then((string) {
     _mapStyle = string;
   });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

        body: SafeArea(child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('core')
                .doc("events")
                .collection("Kazan").snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return GoogleMap(

                initialCameraPosition: _kGooglePlex,
                markers:Set<Marker>.of(getEventsMarker(snapshot)),
                padding: EdgeInsets.fromLTRB(0, 0, 0, 60) +
                    MediaQuery
                        .of(context)
                        .padding,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  controller.setMapStyle(_mapStyle);


                },
              );
            })),);
  }



  getEventsMarker(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<Marker> markers = <Marker>[];
    if (snapshot.hasData)
      snapshot.data!.docs.forEach((document) {
        GeoPoint tempGeoPoint = document["eventPosition"]["geopoint"] as GeoPoint;
        markers.add(
            Marker(
                markerId: MarkerId(document.id),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                position: LatLng(tempGeoPoint.latitude, tempGeoPoint.longitude),
                infoWindow: InfoWindow(
                  title: document["eventName"],
                )
            )
        );
      });
    var t = Set<Marker>.of(markers);
    return markers;

  }

}
