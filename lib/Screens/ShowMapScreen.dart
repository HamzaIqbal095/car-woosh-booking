import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:woooosh/Objects/CompanyObject.dart';
import 'package:woooosh/Utils/CustomMarkerClass.dart';

class MapScreen extends StatefulWidget {
  final List<CompanyObject> companies;

  const MapScreen({Key key, @required this.companies}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> markers = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: const CameraPosition(
                target: LatLng(32.1766899, 74.2061979), zoom: 20),
            markers: markers.toSet(),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print(widget.companies.length);
    MarkerGenerator(markerWidgets(), (bitmaps) {
      setState(() {
        markers = mapBitmapsToMarkers(bitmaps);
      });
    }).generate(context);
  }

  List<Marker> mapBitmapsToMarkers(List<Uint8List> bitmaps) {
    List<Marker> markersList = [];
    bitmaps.asMap().forEach((i, bmp) {
      final city = widget.companies[i];
      markersList.add(
        Marker(
          markerId: MarkerId(city.companyName),
          position: city.currentLocation,
          onTap: () => {
            print('m called for marker'),
          },
          icon: BitmapDescriptor.fromBytes(bmp),
        ),
      );
    });
    return markersList;
  }

  List<Widget> markerWidgets() {
    return widget.companies.map((c) => _getMarkerWidget(c)).toList();
  }
}

// Example of marker widget
Widget _getMarkerWidget(CompanyObject company) {
  // return FutureBuilder(
  //     future: FirebaseStorageService()
  //         .getImageLink(imageName: company.imageName, folderName: 'Companies'),
  //     builder: (BuildContext contextBuild, AsyncSnapshot<String> snapshot) {
  //       if (snapshot.data != null) {
  return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
      child: Column(
        children: [
          const Icon(
            Icons.location_history_rounded,
            size: 100,
          ),
          Text(
            company.companyName,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ));
  //   } else {
  //     return const SizedBox();
  //   }
  // });
}

// Example of backing data
// List<City> cities = [
//   City("Zagreb", LatLng(32.1766899, 74.2061979)),
//   City("Ljubljana", LatLng(32.1766939, 74.2062088)),
//   // City("Novo Mesto", LatLng(45.806132, 15.160768)),
//   // City("Varaždin", LatLng(46.302111, 16.338036)),
//   // City("Maribor", LatLng(46.546417, 15.642292)),
//   // City("Rijeka", LatLng(45.324289, 14.444480)),
//   // City("Karlovac", LatLng(45.489728, 15.551561)),
//   // City("Klagenfurt", LatLng(46.624124, 14.307974)),
//   // City("Graz", LatLng(47.060426, 15.442028)),
//   // City("Celje", LatLng(46.236738, 15.270346))
// ];
//
// class City {
//   final String name;
//   final LatLng position;
//
//   City(this.name, this.position);
// }
