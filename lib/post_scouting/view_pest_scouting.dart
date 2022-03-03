import 'package:crophq/ChTextStyle.dart';
import 'package:crophq/api_base.dart';
import 'package:crophq/location_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewPestScouting extends StatefulWidget {
  final _scoutData;

  ViewPestScouting(this._scoutData);

  @override
  State<StatefulWidget> createState() {
    return _ViewPestScoutingState();
  }
}

class _ViewPestScoutingState extends State<ViewPestScouting> {
  @override
  Widget build(BuildContext context) {
    int severity = widget._scoutData['severity'] ?? 0;
    print(severity);
    if (severity > 3) {
      severity = 3;
    }

    if (severity < 0) {
      severity = 0;
    }
    //print("second $severity");

    return Scaffold(
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
                    child: Container(
                      height: 160,
                      child: Image.network(
                        ApiBase.instance.requests.systemIp +
                            widget._scoutData['imagePath'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              FlatButton(
                padding: EdgeInsets.all(0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Icon(
                      Icons.location_on,
                    ),
                    Text("View Location")
                  ],
                ),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LocationPicker(
                        singleLocation: true,
                        initialMarkers: [
                          LatLng(widget._scoutData['latitude'],
                              widget._scoutData['longitude'])
                        ],
                        fixed: true,
                      ),
                    ),
                  );
                },
              ),
              Padding(padding: EdgeInsets.only(top: 8)),
              Text(
                "Farm",
                style: ChTextStyle.primaryBold,
              ),
              Text(
                widget._scoutData['farm'],
                style: ChTextStyle.primaryText,
              ),
              Padding(padding: EdgeInsets.only(top: 16)),
              Text(
                "Pest",
                style: ChTextStyle.primaryBold,
              ),
              Text(
                widget._scoutData['pest'],
                style: ChTextStyle.primaryText,
              ),
              Padding(padding: EdgeInsets.only(top: 16)),
              Text(
                "Severity",
                style: ChTextStyle.primaryBold,
              ),
              Text(
                ["", "Low", "Medium", "High"][severity],
                style: ChTextStyle.primaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
