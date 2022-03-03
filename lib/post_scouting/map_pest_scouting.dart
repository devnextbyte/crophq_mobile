import 'dart:async';

import 'package:crophq/api_base.dart';
import 'package:crophq/post_scouting/view_pest_scouting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:search_map_place/search_map_place.dart';

import 'add_pest_scouting.dart';

class MapPestScouting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MapPestScoutingState();
  }
}

class _MapPestScoutingState extends State<MapPestScouting> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng _position;
  var _scoutings = List<dynamic>();
  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (position == null) {
      position = await getLastKnownPosition();
    }
    
    if (position != null) {
      setState(() {
        _position = LatLng(position.latitude, position.longitude);
      });
    } else {
      setState(() {
        _position = LatLng(0, 0);
      });
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Failed to fetch location"),
            );
          },
        );
      });
    }
  }

  void _loadData() {
    Future.delayed(Duration.zero, () {
      ApiBase.instance.requests.getScoutings.execute(context, body: {
        "Page": 1,
        "PageSize": 100,
      }).then((val) {
        setState(() {
          _scoutings = val['data'];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pest and Disease Scouting"),
      ),
      floatingActionButton: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left:32),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => AddPestScouting()));
                _loadData();
              },
            ),
          ),
        ],
      ),
      body: _position == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
            children: [
              GoogleMap(
                  mapType: MapType.satellite,
                  initialCameraPosition:
                      CameraPosition(target: _position, zoom: 22),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: _scoutings.map(
                    (scout) {
                      final id = scout['id'];
                      return Marker(
                        markerId: MarkerId("$id"),
                        position: LatLng(scout['latitude'], scout['longitude']),
                        icon: BitmapDescriptor.defaultMarker,
                        // onTap: () {
                        //   Navigator.of(context).push(
                        //     MaterialPageRoute(
                        //       builder: (context) => ViewPestScouting(scout),
                        //     ),
                        //   );
                        // },
                        infoWindow: InfoWindow(
                            title: scout['pest'],
                            snippet: scout['farm'],
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ViewPestScouting(scout),
                                ),
                              );
                            }),
                      );
                    },
                  ).toSet(),
                ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SearchMapPlaceWidget(
                    apiKey: "AIzaSyDiPyWgorCzrSFQSU_efuahuJ9zkc6Ui2U",
                    // The language of the autocompletion
                    language: 'en',
                    // The position used to give better recomendations. In this case we are using the user position
                    location: _position,
                    radius: 30000,
                    onSelected: (Place place) async {
                      final geolocation = await place.geolocation;
//                      print("Hello Resp"+geolocation.fullJSON);

//                     Will animate the GoogleMap camera, taking us to the selected position with an appropriate zoom
                      final GoogleMapController controller =
                      await _controller.future;
                      controller.animateCamera(
                          CameraUpdate.newLatLng(geolocation.coordinates));
                      controller.animateCamera(CameraUpdate.newLatLngBounds(
                          geolocation.bounds, 0));
                    },
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
