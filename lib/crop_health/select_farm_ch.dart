import 'package:crophq/api_base.dart';
import 'package:crophq/crop_health/view_crop_health.dart';
import 'package:flutter/material.dart';

import '../ChTextStyle.dart';

class SelectFarmCh extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SelectFarmChState();
  }
}

class _SelectFarmChState extends State<SelectFarmCh> {
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
      ),
      
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemBuilder: (context, i) {
            if (i < _farms.length) {
              return GestureDetector(
                onTap: () async {
                  if (_farms[i]['crops'] != null) {
                    String csv = "";
                    for (final crop in _farms[i]['crops']) {
                      csv += crop["name"];
                      csv += ",";
                    }
                    _farms[i]['crops'] = csv;
                  }

                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ViewCropHealth(_farms[i]),
                  ));
                  loadList();
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
