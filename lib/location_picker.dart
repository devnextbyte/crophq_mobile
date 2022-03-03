import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:search_map_place/search_map_place.dart';

class LocationPicker extends StatefulWidget {
  final List<LatLng> _markers;
  final bool _fixed;
  final bool _singleLocation;

  LocationPicker(
      {List<LatLng> initialMarkers, fixed = false, singleLocation = false})
      : _markers = initialMarkers ?? List<LatLng>(),
        _fixed = fixed && initialMarkers.length > 0,
        _singleLocation = singleLocation;

  @override
  State<LocationPicker> createState() => _LocationPickerState(_markers);
}

class _LocationPickerState extends State<LocationPicker> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng _position;

  @override
  void initState() {
    super.initState();

    if (_position == null) {
      _loadLocation();
    }
  }

  _LocationPickerState(List<LatLng> markers) {
    if (markers != null && markers.length > 0) {
      double latSum = 0;
      double lngSum = 0;

      markers.forEach((marker) {
        latSum += marker.latitude;
        lngSum += marker.longitude;
      });

      _position = LatLng(latSum / markers.length, lngSum / markers.length);
      //print("$_position");
    } else {
      _position = null;
    }
  }

  Future<void> _loadLocation() async {
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (!widget._fixed) {
      actions.add(
        IconButton(
          icon: Icon(Icons.undo),
          onPressed: () {
            setState(() {
              widget._markers.removeLast();
            });
          },
        ),
      );
    }

    return new Scaffold(
      appBar: AppBar(title: Text("Location Picker"), actions: actions),
      floatingActionButton: widget._fixed
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) => Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: FloatingActionButton(
                      onPressed: () {
                        if (widget._singleLocation) {
                          if (widget._markers.length > 0) {
                            Navigator.of(context).pop(widget._markers);
                          } else {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please select location first"),
                              ),
                            );
                          }
                        } else {
                          if (widget._markers.length > 2) {
                            Navigator.of(context).pop(widget._markers);
                          } else {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Mark all corners of the farm field"),
                              ),
                            );
                          }
                        }
                      },
                      tooltip: 'Done',
                      child: Icon(Icons.done),
                    ),
                  ),
                ),
              ],
            ),
      body: _position == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
//                  mapToolbarEnabled: true,
                  mapType: MapType.satellite,
                  initialCameraPosition: CameraPosition(
                    target: _position,
                    zoom: 22,
                  ),
//                  myLocationEnabled: true,
//                  myLocationButtonEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  onTap: widget._fixed
                      ? null
                      : (LatLng position) {
                          setState(() {
                            if (widget._singleLocation &&
                                widget._markers.length > 0) {
                              widget._markers[0] = position;
                            } else {
                              widget._markers.add(position);
                            }
                          });
                        },
                  markers: widget._markers
                      .map((position) => Marker(
                            markerId: MarkerId(position.toString()),
                            draggable: true,
                            position: position,
                            icon: BitmapDescriptor.defaultMarker,
                          ))
                      .toSet(),
                  polygons: getPolygon(),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SearchMapPlaceWidget(
                      apiKey: "AIzaSyAYsynBKd8QYnpu9IE7YnfFc3NiQ_rLU58",
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

  Set<Polygon> getPolygon() {
    List<Polygon> polygon = List();
    List<LatLng> tempMark = List.from(widget._markers);
    if (widget._markers.length > 0) {
      tempMark.add(widget._markers[0]);
    }
    if (tempMark.length > 1) {
      polygon.add(Polygon(
        polygonId: PolygonId("onlyOne"),
        points: tempMark,
        fillColor: Colors.red.withOpacity(0.3),
        strokeWidth: 2,
        strokeColor: Colors.red,
      ));
    }

    return polygon.toSet();
  }

// Future<void> _goToTheLake(LatLng pos) async {
//   final GoogleMapController controller = await _controller.future;
//   controller.animateCamera(CameraUpdate.newCameraPosition(
//       CameraPosition(target: pos, zoom: _zoom)));
// }

}
