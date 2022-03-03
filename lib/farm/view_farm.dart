import 'package:crophq/api_base.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../ChTextStyle.dart';
import '../location_picker.dart';
import 'add_farm.dart';

class ViewFarm extends StatefulWidget {
  final dynamic _farmData;

  ViewFarm(this._farmData);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ViewFarmState();
  }
}

class _ViewFarmState extends State<ViewFarm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String farmUrl;
    final listOfImage = widget._farmData['images'];
    if (listOfImage != null && listOfImage.length > 0) {
      farmUrl = listOfImage[listOfImage.length - 1];
      farmUrl = ApiBase.instance.requests.systemIp + farmUrl;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("View Farm"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              int id = widget._farmData["id"];
              ApiBase.instance.requests.deleteFarm
                  .execute(context, pathVar: {"FarmId": "$id"}).then((val) {
                if (val != null) {
                  Navigator.of(context).pop();
                }
              });
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddFarm(
                    farmData: widget._farmData,
                  )));
          // _loadData(context);
          Navigator.of(context).pop();
        },
        child: Icon(Icons.edit),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 160,
                    child: farmUrl != null && farmUrl.isNotEmpty
                        ? Image.network(
                            farmUrl,
                            fit: BoxFit.cover,
                          )
                        : Container(),
                  ),
                ),
              ],
            ),
            FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LocationPicker(
                      fixed: true,
                      initialMarkers: List<LatLng>.from(
                        widget._farmData["locations"].map((locObj) {
                          return LatLng(
                              locObj['latitude'], locObj['longitude']);
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(Icons.location_on),
                  Text("View on Map")
                ],
              ),
            ),
            Text(
              "Name",
              style: ChTextStyle.primaryBold,
            ),
            Padding(
              padding: EdgeInsets.only(top: 4),
            ),
            Text(
              widget._farmData['name'] ?? "",
              style: ChTextStyle.primaryText,
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
            ),
            Text(
              "Crop(s)",
              style: ChTextStyle.primaryBold,
            ),
            Padding(
              padding: EdgeInsets.only(top: 4),
            ),
            Text(
              widget._farmData['crops'] ?? "",
              style: ChTextStyle.primaryText,
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
            ),
            Text(
              "Town",
              style: ChTextStyle.primaryBold,
            ),
            Padding(
              padding: EdgeInsets.only(top: 4),
            ),
            Text(
              widget._farmData['region'] ?? "",
              style: ChTextStyle.primaryText,
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
            ),
            Text(
              "Country",
              style: ChTextStyle.primaryBold,
            ),
            Padding(
              padding: EdgeInsets.only(top: 4),
            ),
            Text(
              widget._farmData['country'] ?? "",
              style: ChTextStyle.primaryText,
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
            ),
          ],
        ),
      ),
    );
  }
}
