import 'package:crophq/api_base.dart';
import 'package:crophq/weather/weather.dart';
import 'package:flutter/material.dart';

import '../ChTextStyle.dart';

class SelectWeatherFarm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SelectWeatherFarmState();
  }
}

class _SelectWeatherFarmState extends State<SelectWeatherFarm> {
  var _farms = [];

  @override
  void initState() {
    super.initState();
    loadList();
  }

  void loadList() {
    Future.delayed(Duration.zero, () {
      ApiBase.instance.requests.getFarms
          .execute(context, body: {"Page": 1, "PageSize": 100}).then((farms) {
        if (farms != null) {
          setState(() {
            _farms = farms['data'];
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Farm"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemBuilder: (context, i) {
            if (i < _farms.length) {
              return GestureDetector(
                onTap: () async {
                  final currentFarm = _farms[i];
                  int length = currentFarm["locations"].length;
                  double latSum = 0;
                  double lngSum = 0;

                  currentFarm["locations"].forEach((loc) {
                    latSum += loc['latitude'];
                    lngSum += loc['longitude'];
                  });
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Weather("${latSum / length},${lngSum / length}"),
                  ));
                },
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 8, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _farms[i]['name'].toString().toUpperCase(),
                          style: ChTextStyle.primaryBold,
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                _farms[i]['region'],
                                style: ChTextStyle.primaryText,
                              ),
                            ),
                            Text(
                              _farms[i]['createdDate'],
                              style: ChTextStyle.secondaryText,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }
}
