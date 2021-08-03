import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_flutter/core/Utils.dart';
import 'package:test_flutter/ui/eventInfo/event_info_widget.dart';
import 'package:test_flutter/ui/eventList/myListsWidget.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  bool isLoading = false;
  BitmapDescriptor? myIcon;

  String? _mapStyle;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    rootBundle.loadString('assets/mapStyle.json').then((string) {
      _mapStyle = string;
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'assets/map_marker.png')
        .then((onValue) {
      myIcon = onValue;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('core')
                  .doc("events")
                  .collection("list")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                return Stack(children: [
                  GoogleMap(
                    initialCameraPosition: _kGooglePlex,
                    markers: Set<Marker>.of(getEventsMarker(snapshot)),
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 60) +
                        MediaQuery.of(context).padding,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      controller.setMapStyle(_mapStyle);
                    },
                  ),
                  Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.event),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MyListsWidget()));
                        },
                      )),
                ]);
              })),
    );
  }

  getEventsMarker(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<Marker> markers = <Marker>[];
    if (snapshot.hasData)
      snapshot.data!.docs.forEach((document) {
        GeoPoint tempGeoPoint =
            document["eventPosition"]["geopoint"] as GeoPoint;
        markers.add(Marker(
            markerId: MarkerId(document.id),
            icon: myIcon!,
            position: LatLng(tempGeoPoint.latitude, tempGeoPoint.longitude),
            infoWindow: InfoWindow(
              title: document["eventName"],
            ),

            onTap: () {
              Utils.getInfoAboutEvent(document.id).then((value) => {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => EventInfoWidget(value.id))),

                  });
            }));
      });
    return markers;
  }
}
