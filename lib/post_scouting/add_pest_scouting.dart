import 'dart:convert';
import 'dart:io';

import 'package:crophq/api_base.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AddPestScouting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddPestScoutingState();
  }
}

class _AddPestScoutingState extends State<AddPestScouting> {
  File _imageFile;
  var _farms = List<dynamic>();
  var _pests = List<dynamic>();
  var _selectedFarm;
  var _selectedPests;
  var _selectedSeverity;
  LatLng _location;
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  Future<void> _loadLocation() async {
    Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (position == null) {
      position = await getLastKnownPosition();
    }

    if (position != null) {
      setState(() {
        _location = LatLng(position.latitude, position.longitude);
      });
    } else {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Failed to fetch location, try again?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Yes"),
                  onPressed: () {
                    _loadLocation();
                  },
                ),
                FlatButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLocation();
    Future.delayed(Duration.zero, () async {
      final pests = await ApiBase.instance.requests.getPests.execute(context);
      if (pests == null) {
        return;
      }

      var farms = await ApiBase.instance.requests.getFarms
          .execute(context, body: {"Page": 1, "PageSize": 100});
      if (farms == null) {
        return;
      }

      setState(() {
        _farms = farms['data'].map((f) {
          return {"id": f['id'], "name": f['name']};
        }).toList();
        _pests = pests['data'];

        if (_farms != null && _farms.length > 0) {
          _selectedFarm = _farms[0];
        }

        if (_pests != null && _pests.length > 0) {
          _selectedPests = _pests[0];
        }

        _selectedSeverity = "1";
      });
    });
  }

  Future _getImage(ImageSource source) async {
    var image = await ImagePicker().getImage(source: source, maxHeight: 200);
    setState(() {
      _imageFile = File( image.path);
    });
  }

  Widget getOptions() {
    return Container(
      child: new Wrap(
        children: <Widget>[
          new ListTile(
              leading: new Icon(Icons.music_note),
              title: new Text('Music'),
              onTap: () => {}),
          new ListTile(
            leading: new Icon(Icons.videocam),
            title: new Text('Video'),
            onTap: () => {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("Pest and Disease Scouting"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _key.currentState.showBottomSheet(
                          (ctx) => Container(
                            child: new Wrap(
                              children: <Widget>[
                                new ListTile(
                                  leading: new Icon(Icons.camera),
                                  title: new Text('Camera'),
                                  onTap: () => _getImage(ImageSource.camera),
                                ),
                                new ListTile(
                                  leading: new Icon(Icons.image),
                                  title: new Text('Gallery'),
                                  onTap: () => _getImage(ImageSource.gallery),
                                ),
                              ],
                            ),
                          ),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        );
                      },
                      child: Container(
                        height: 160,
                        child: _imageFile == null
                            ? Card(
                                child: Icon(Icons.camera, size: 80),
                              )
                            : Image.file(
                                _imageFile,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              Center(child: Text("Please take a photo of the pest")),
              Padding(padding: EdgeInsets.only(top: 16)),
              Padding(
                padding: EdgeInsets.only(top: 8),
              ),
              Text("Select Farm"),
              DropdownButton(
                isExpanded: true,
                value: _selectedFarm,
                onChanged: (val) {
                  setState(() {
                    _selectedFarm = val;
                  });
                },
                items: _farms.map((f) {
                  return DropdownMenuItem(
                    value: f,
                    child: Text(f['name']),
                  );
                }).toList(),
              ),
              Text("Select Pest"),
              DropdownButton(
                isExpanded: true,
                value: _selectedPests,
                onChanged: (val) {
                  setState(() {
                    _selectedPests = val;
                  });
                },
                items: _pests.map((f) {
                  return DropdownMenuItem(
                    value: f,
                    child: Text(f['crop']),
                  );
                }).toList(),
              ),
              Text("Select Severity"),
              DropdownButton(
                isExpanded: true,
                value: _selectedSeverity,
                onChanged: (val) {
                  setState(() {
                    _selectedSeverity = val;
                  });
                },
                items: ["1", "2", "3"].map((s) {
                  int pos = (int.parse(s) ?? 1) - 1;
                  if (pos > 2) {
                    pos = 2;
                  }

                  if (pos < 0) {
                    pos = 0;
                  }
                  return DropdownMenuItem(
                    value: s,
                    child: Text(["Low", "Medium", "High"][pos]),
                  );
                }).toList(),
              ),
              Builder(
                builder: (ctx) => Row(
                  children: <Widget>[
                    Expanded(
                      child: _location == null
                          ? Center(child: CircularProgressIndicator())
                          : RaisedButton(
                              onPressed: () async {
                                if (_selectedPests != null &&
                                    _selectedFarm != null &&
                                    _imageFile != null &&
                                    _location != null) {
                                  final resp = await ApiBase
                                      .instance.requests.addPestScouting
                                      .execute(context, body: {
                                    "pestId": _selectedPests['id'],
                                    "farmId": _selectedFarm['id'],
                                    "image": base64Encode(
                                        _imageFile.readAsBytesSync()),
                                    "severity": _selectedSeverity,
                                    "longitude": _location.longitude,
                                    "latitude": _location.latitude
                                  });
                                  if (resp != null) {
                                    Navigator.of(context).pop();
                                  }
                                } else {
                                  Scaffold.of(ctx).showSnackBar(SnackBar(
                                      content: Text("Enter all data")));
                                }
                              },
                              child: Text("Send"),
                            ),
                    ),
                  ],
                ),
              ),
              _location == null
                  ? Center(child: Text("Fetching Location"))
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
