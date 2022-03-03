import 'package:crophq/api_base.dart';
import 'package:crophq/farm_record/view_farm_record.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart' as path;

import '../ChTextStyle.dart';
import 'add_farm_record.dart';

class FarmRecordList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FarmRecordListState();
  }
}

class _FarmRecordListState extends State<FarmRecordList> {
  var _farms = [];
  var _farmIds = [];
  var _farmId = -999;

  @override
  void initState() {
    super.initState();
    loadFarms();
  }

  void loadFarms() {
    Future.delayed(Duration.zero, () {
      ApiBase.instance.requests.getFarms
          .execute(context, body: {"Page": 1, "PageSize": 10}).then((gotFarms) {
        if (gotFarms != null) {
          setState(() {
            _farmIds = gotFarms['data'];
            _farmIds.add({"id": null, "name": "Remove filter"});
          });

          loadData();
        }
      });
    });
  }

  void loadData({int farmId}) {
    Future.delayed(Duration.zero, () {
      final body = {
        "Page": 1,
        "PageSize": 100,
      };

      if (farmId != null) {
        body["FarmId"] = farmId;
      }

      ApiBase.instance.requests.activities
          .execute(context, body: body)
          .then((val) {
        if (val != null) {
          setState(() {
            _farms = val["data"];
          });
        }
      });
    });
  }

  void loadPdf(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      final body = {
        "Page": 1,
        "PageSize": 100,
      };

      if (_farmId != -999) {
        body["FarmId"] = _farmId;
      }
      final directory = await path.getExternalStorageDirectory();
      //print("path ${directory.path}");
      DateTime time = DateTime.now();
      String fileName =
          "${time.month}${time.day}${time.hour}${time.minute}${time.second}";
      String filePath = "${directory.path}/pdf_$fileName.pdf";
      ApiBase.instance.requests.activitiesPdf
          .execute(context,
              body: body, filePath: filePath)
          .then((val) {
        if (val != null) {
          OpenFile.open(filePath);
          // showDialog(context: context, builder: (c){
          //   return AlertDialog(content: Text(""),);
          // });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Farm Activities"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.file_download),
              onPressed: () {
                loadPdf(context);
              }),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Select Farm"),
                      content: ListView(
                        children: _farmIds.map((listFarm) {
                          return FlatButton(
                            child: Row(
                              mainAxisAlignment: listFarm['id'] != null
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.center,
                              children: <Widget>[
                                listFarm['id'] != null
                                    ? Text(listFarm['name'])
                                    : Text(listFarm['name'],
                                        style: TextStyle(color: Colors.black)),
                              ],
                            ),
                            onPressed: () {
                              Future.delayed(Duration(milliseconds: 150), () {
                                Navigator.of(context).pop();
                                _farmId = listFarm['id'];
                                loadData(farmId: listFarm['id']);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    );
                  });
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddFarmRecord()));
          loadData();
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemBuilder: (context, i) {
            if (i < _farms.length) {
              return GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ViewFarmRecord(_farms[i])));
                  loadData();
                },
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_farms[i]["activity"],
                            style: ChTextStyle.primaryBold),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                _farms[i]['farmName'],
                              ),
                            ),
                            Text(_farms[i]['createdDate'],
                                style: ChTextStyle.secondaryText)
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
