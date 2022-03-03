import 'dart:convert';
import 'dart:io';

import 'package:crophq/ChTextStyle.dart';
import 'package:crophq/location_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../api_base.dart';

class AddFarm extends StatefulWidget {
  final _initialData;
  final _name = TextEditingController();

  AddFarm({bool firstEntry = false, dynamic farmData, List<LatLng> locations})
      : _initialData = farmData;

  @override
  State<StatefulWidget> createState() {
    return _AddFarmState();
  }
}

class _AddFarmState extends State<AddFarm> {
  var _locations = List<LatLng>();
  List<dynamic> _countries; // = [];
  List<dynamic> _cities; // = [];

  dynamic _selectedCountry;
  dynamic _selectedCity;
  int _selectedCityId = -1;

  List<dynamic> _cropCategories; // = [];
  List<dynamic> _crops; // = [];

  dynamic _selectedCropCategory;
  dynamic _selectedCrop;
  List<dynamic> _selectedCrops = [];

  File _imageFile;
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      print("Loading start");
      final cities =
          await ApiBase.instance.requests.getAllCities.execute(context);
      if (cities == null) {
        print("Cities null");
        return;
      }

      final crops =
          await ApiBase.instance.requests.getAllCrops.execute(context);
      if (crops == null) {
        print("Crops null");
        return;
      }

      setState(() {
        _countries = cities['data'];
        if (_countries != null && _countries.length > 0) {
          _cities = _countries[0]["regions"];
          _selectedCountry = _countries[0];
          if (_cities != null && cities.length > 0) {
            _selectedCity = _cities[0];
            _selectedCityId = _cities[0]["id"];
          }
        }

        _cropCategories = crops['data'];
        if (_cropCategories != null && _cropCategories.length > 0) {
          _selectedCropCategory = _cropCategories[0];
          _crops = _selectedCropCategory["crops"];
          if (_crops != null && _crops.length > 0) {
            _selectedCrop = _crops[0];
          }
        }
      });

      if (widget._initialData != null) {
        print(widget._initialData);
        List<String> inputCrop = widget._initialData['crops'].split(",");
        _cropCategories.forEach((category) => category['crops'].forEach((crop) {
              if (inputCrop.contains(crop["crop"])) {
                _selectedCrops.add(crop);
              }
            }));

        setState(() {
          widget._name.text = widget._initialData['name'] ?? "";

          String country = widget._initialData['country'] ?? "";
          if (country.isNotEmpty) {
            final selectedCountryObj = _countries.firstWhere((itrCountry) {
              return itrCountry['country'] == country;
            }, orElse: () {
              return null;
            });
            if (selectedCountryObj != null) {
              _selectedCountry = selectedCountryObj;
              _cities = selectedCountryObj['regions'] ?? _cities;
            }
          }
          String city = widget._initialData['region'] ?? "";
          //print("got city: $city");
          if (city.isNotEmpty) {
            final selectedCityObj = _cities.firstWhere((itrCity) {
              return itrCity['region'] == city;
            }, orElse: () {
              return null;
            });
            if (selectedCityObj != null) {
              _selectedCity = selectedCityObj;
              _selectedCityId = selectedCityObj['id'] ?? _selectedCityId;
            }
          }

          if (widget._initialData['locations'] != null) {
            List<dynamic> loc = widget._initialData['locations'];
            for (final locObj in loc) {
              _locations.add(LatLng(locObj['latitude'], locObj['longitude']));
            }
          }
        });
      }
      print("All data loaded");
    });

  }

  Future _getImage(ImageSource source) async {
    Navigator.of(context).pop();
    print("getimage");
    var image = await ImagePicker().getImage(source: source, maxHeight: 200);

    setState(() {
      _imageFile = File(image.path);
    });
  }

  @override
  Widget build(BuildContext c) {
    String farmUrl;
    if (widget._initialData != null) {
      final listOfImage = widget._initialData['images'];
      if (listOfImage != null && listOfImage.length > 0) {
        farmUrl = listOfImage[listOfImage.length - 1];
        farmUrl = ApiBase.instance.requests.systemIp + farmUrl;
      }
    }

    return Scaffold(
        key: _key,
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget._initialData == null ? "Add Farm" : "Edit Farm"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
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
                              ? (farmUrl == null || farmUrl.isEmpty)
                                  ? Card(
                                      elevation: 8,
                                      child: Icon(Icons.camera, size: 80),
                                    )
                                  : Image.network(
                                      farmUrl,
                                      fit: BoxFit.cover,
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
                FlatButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () async {
                    List<LatLng> markers = await Navigator.of(c).push(
                      MaterialPageRoute(
                        builder: (context) => LocationPicker(
                          initialMarkers: _locations,
                        ),
                      ),
                    );
                    if (markers != null) {
                      setState(() {
                        _locations = markers;
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Icon(Icons.location_on),
                      Text(_locations.length < 3
                          ? "Set Location"
                          : "Change Location")
                    ],
                  ),
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Name"),
                  controller: widget._name,
                  style: ChTextStyle.primaryText,
                ),
                Padding(padding: EdgeInsets.only(top: 16)),
                Text(
                  "Country",
                  textAlign: TextAlign.start,
                  style: ChTextStyle.secondaryText,
                ),
                _countries != null && _countries.length > 0
                    ? DropdownButton(
                        isExpanded: true,
                        items: _countries.map((countryObj) {
                          return DropdownMenuItem(
                            value: countryObj,
                            child: Text(countryObj["country"]),
                          );
                        }).toList(),
                        value: _selectedCountry,
                        onChanged: (val) {
                          setState(() {
                            _cities = val['regions'];
                            if (_cities != null && _cities.length > 0) {
                              _selectedCity = _cities[0];
                              _selectedCityId = _selectedCity['id'];
                            }
                            _selectedCountry = val;
                          });
                        },
                      )
                    : Divider(),
                Padding(padding: EdgeInsets.only(top: 16)),
                Text("Region"),
                _cities != null && _cities.length > 0
                    ? DropdownButton(
                        isExpanded: true,
                        items: _cities.map(
                          (cityObj) {
                            return DropdownMenuItem(
                              value: cityObj,
                              child: Text(cityObj['region']),
                            );
                          },
                        ).toList(),
                        value: _selectedCity,
                        onChanged: (selectedCityObj) {
                          setState(() {
                            _selectedCity = selectedCityObj;
                          });
                          _selectedCityId = selectedCityObj['id'];
                        },
                      )
                    : Divider(),
                Padding(padding: EdgeInsets.only(top: 16)),
                Card(
                  elevation: 8,
                  margin: EdgeInsets.all(0),
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text("Select Crop Category: "),
                                ),
                                Expanded(
                                  child: _cropCategories == null
                                      ? Divider()
                                      : DropdownButton(
                                          isExpanded: true,
                                          onChanged: (val) {
                                            setState(() {
                                              _selectedCropCategory = val;

                                              _crops = _selectedCropCategory[
                                                      'crops'] ??
                                                  [];
                                              if (_crops.length > 0) {
                                                _selectedCrop = _crops[0];
                                              } else {
                                                _selectedCrop = null;
                                              }
                                              print(
                                                  "selected crop : ${_crops.toString()}");
                                            });
                                          },
                                          value: _selectedCropCategory,
                                          items:
                                              _cropCategories.map((category) {
                                            return DropdownMenuItem(
                                              child: Text(
                                                  category['category'] ?? ""),
                                              value: category,
                                            );
                                          }).toList(),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text("Select Crop: "),
                                ),
                                Expanded(
                                  child: _crops == null
                                      ? Divider()
                                      : DropdownButton(
                                          isExpanded: true,
                                          onChanged: (val) {
                                            setState(() {
                                              _selectedCrop = val;
                                            });
                                          },
                                          value: _selectedCrop,
                                          items: _crops.map((crop) {
                                            return DropdownMenuItem(
                                              child: Text(crop['crop'] ?? ""),
                                              value: crop,
                                            );
                                          }).toList(),
                                        ),
                                ),
                              ],
                            ),
                          ),
                          AbsorbPointer(
                            absorbing: _selectedCrop == null,
                            child: FlatButton(
                              child: Text("Add"),
                              onPressed: () {
                                if (_crops == null) {
                                  return;
                                }
                                setState(() {
                                  _selectedCrops.add(_selectedCrop);
                                  _crops = _crops.where((crop) {
                                    return !_selectedCrops.contains(crop);
                                  }).toList();
                                  if (_crops.length > 0) {
                                    _selectedCrop = _crops[0];
                                  } else {
                                    _selectedCrop = null;
                                    _crops = [];
                                  }
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: _selectedCrops.map<Widget>((final crop) {
                    return Row(
                      children: <Widget>[
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(crop['crop']),
                        )),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _selectedCrops.remove(crop);
                              _crops.add(crop);
                            });
                          },
                        )
                      ],
                    );
                  }).toList(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 24),
                ),
                Builder(
                  builder: (ctx) => Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          onPressed: () async {
                            if (!validate(ctx)) {
                            } else {
                              final enteredData = {
                                "name": widget._name.text,
                                "regionId": _selectedCityId,
                                "radius": 1,
                                "crops": _selectedCrops.map((crop) {
                                  int id = crop["id"];
                                  return "$id";
                                }).toList(),
                                "locations": _locations.map((loc) {
                                  return {
                                    "longitude": loc.longitude,
                                    "latitude": loc.latitude
                                  };
                                }).toList()
                              };
                              var request;
                              if (widget._initialData != null) {
                                enteredData['farmId'] =
                                    widget._initialData['id'];
                                request = ApiBase.instance.requests.updateFarm;
                              } else {
                                request = ApiBase.instance.requests.createFarm;
                              }

                              final onValue = await request.execute(
                                context,
                                body: enteredData,
                              );
                              if (onValue == null || _imageFile == null) {
                                if (_imageFile == null) {
                                  Navigator.of(context).pop();
                                }
                                return;
                              }

                              final onImageValue = await ApiBase
                                  .instance.requests.addFarmImage
                                  .execute(context, body: {
                                "farmId": onValue['data']['id'],
                                "image":
                                    base64Encode(_imageFile.readAsBytesSync()),
                              });

                              if (onImageValue != null) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          child: Text("Save"),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  bool validate(BuildContext ctx) {
    String errorMessage = "";
    if (_locations == null || _locations.length < 3) {
      errorMessage = "Please provide farm location";
    } else if (widget._name.text.isEmpty) {
      errorMessage = "Please enter farm name";
    } else if (_selectedCityId == -1) {
      errorMessage = "Please select your region";
    } else if (_selectedCrops.length < 1) {
      errorMessage = "Please add atleast one crop";
    }

    if (errorMessage.isEmpty) {
      return true;
    } else {
      Scaffold.of(ctx).showSnackBar(SnackBar(content: Text(errorMessage)));
      return false;
    }
  }
}
