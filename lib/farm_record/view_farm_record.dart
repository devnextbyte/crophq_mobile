import 'package:crophq/ChTextStyle.dart';
import 'package:crophq/api_base.dart';
import 'package:flutter/material.dart';

import 'add_farm_record.dart';

class ViewFarmRecord extends StatefulWidget {
  final _data;

  ViewFarmRecord(this._data);

  @override
  State<StatefulWidget> createState() {
    return _ViewFarmRecordState();
  }
}

class _ViewFarmRecordState extends State<ViewFarmRecord> {
  @override
  Widget build(BuildContext context) {
    int activityType = widget._data['activityType'] ?? -1;
    String activityTypeString = "";
    if (activityType != -1) {
      activityTypeString = AddFarmRecord.activityTypes[activityType]["name"];
    }

    double cost = widget._data['cost'] ?? -999;
    String costString = "";
    if (cost != -999) {
      costString = cost.toStringAsFixed(2);
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("View Farm Activity"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                int id = widget._data['id'];
                int farmId = widget._data['farmId'];
                //print("id = $id");
                ApiBase.instance.requests.deleteActivity
                    .execute(context, pathVar: {
                  "id": "$id",
                  "farmId": "$farmId",
                }).then((val) {
                  if (val != null) {
                    Navigator.of(context).pop();
                  }
                });
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddFarmRecord(initialData: widget._data),
            ),
          );
          Navigator.of(context).pop();
        },
        child: Icon(Icons.edit),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Name", style: ChTextStyle.primaryBold),
            Text(widget._data['farmName'] ?? "",
                style: ChTextStyle.primaryText),
            Padding(
              padding: EdgeInsets.only(top: 8),
            ),
            Text("Date", style: ChTextStyle.primaryBold),
            Text(widget._data['createdDate'] ?? "",
                style: ChTextStyle.primaryText),
            Padding(
              padding: EdgeInsets.only(top: 8),
            ),
            Text("Activity", style: ChTextStyle.primaryBold),
            Text(widget._data['activity'] ?? "",
                style: ChTextStyle.primaryText),
            Padding(
              padding: EdgeInsets.only(top: 8),
            ),
            Text("Activity Type", style: ChTextStyle.primaryBold),
            Text(activityTypeString, style: ChTextStyle.primaryText),
            Padding(
              padding: EdgeInsets.only(top: 8),
            ),
            Text("Product Used", style: ChTextStyle.primaryBold),
            Text(widget._data['product'] ?? "", style: ChTextStyle.primaryText),
            Padding(
              padding: EdgeInsets.only(top: 8),
            ),
            Text("Cost", style: ChTextStyle.primaryBold),
            Text(costString, style: ChTextStyle.primaryText),
            Padding(
              padding: EdgeInsets.only(top: 8),
            ),
            Text("Comment", style: ChTextStyle.primaryBold),
            Text(widget._data['comment'] ?? "", style: ChTextStyle.primaryText),
            Padding(
              padding: EdgeInsets.only(top: 8),
            ),
          ],
        ),
      ),
    );
  }
}
