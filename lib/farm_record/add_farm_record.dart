import 'package:crophq/ChTextStyle.dart';
import 'package:crophq/api_base.dart';
import 'package:flutter/material.dart';

class AddFarmRecord extends StatefulWidget {
  final _dateController = TextEditingController();
  final _initialData;
  final activity = TextEditingController();
  final productUsed = TextEditingController();
  final comment = TextEditingController();
  final cost = TextEditingController();

  static final activityTypes = [
    {
      "id": 0,
      "name": "Cost",
    },
    {
      "id": 1,
      "name": "Sale",
    },
  ];
  AddFarmRecord({initialData}) : _initialData = initialData {
    if (_initialData != null) {
      activity.text = _initialData['activity'];
      productUsed.text = _initialData['product'];
      comment.text = _initialData['comment'];
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _AddFarmRecordState();
  }
}

class _AddFarmRecordState extends State<AddFarmRecord> {
  List<dynamic> farms;
  var _selectedFarm;
  var _selectedActivityType;

  @override
  void initState() {
    super.initState();
    _selectedActivityType = AddFarmRecord.activityTypes[0];
    if (widget._initialData != null) {
      return;
    }
    Future.delayed(Duration.zero, () {
      ApiBase.instance.requests.getFarms
          .execute(context, body: {"Page": 1, "PageSize": 100}).then((val) {
        if (val != null) {
          setState(() {
            farms = val['data'];
            if (widget._initialData != null) {
              _selectedFarm = farms.firstWhere((farm) {
                return farm['id'] == widget._initialData['id'];
              });
            } else if (farms != null && farms.length > 0) {
              _selectedFarm = farms[0];
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget._initialData == null
              ? "Add Farm Activity"
              : "Edit Farm Activity"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: widget._dateController,
                  onTap: () {
                    _selectDate(widget._dateController);
                  },
                  readOnly: true,
                  decoration: InputDecoration(labelText: "Date"),
                ),
                Padding(padding: EdgeInsets.only(top: 16)),
                widget._initialData == null
                    ? Text("Select Farm")
                    : Text(
                        widget._initialData['farmName']
                            .toString()
                            .toUpperCase(),
                        style: ChTextStyle.primaryBold),
                farms == null
                    ? Divider()
                    : DropdownButton(
                        isExpanded: true,
                        value: _selectedFarm,
                        onChanged: (val) {
                          setState(() {
                            _selectedFarm = val;
                          });
                        },
                        items: farms.map((f) {
                          return DropdownMenuItem(
                            value: f,
                            child: Text(f['name']),
                          );
                        }).toList(),
                      ),
                // Padding(padding: EdgeInsets.only(top: 16)),
                Text("Activity Type"),

                DropdownButton(
                  isExpanded: true,
                  value: _selectedActivityType,
                  onChanged: (val) {
                    setState(() {
                      _selectedActivityType = val;
                    });
                  },
                  items: AddFarmRecord.activityTypes.map((f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(f['name']),
                    );
                  }).toList(),
                ),
                TextField(
                    decoration: InputDecoration(labelText: "Activity"),
                    controller: widget.activity),
                TextField(
                  decoration: InputDecoration(labelText: "Product Used"),
                  controller: widget.productUsed,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Cost"),
                  keyboardType: TextInputType.number,
                  controller: widget.cost,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Comment"),
                  keyboardType: TextInputType.multiline,
                  controller: widget.comment,
                ),
                Padding(padding: EdgeInsets.only(top: 16)),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: () async {
                          final Map<String, dynamic> body = {
                            "activity": widget.activity.text,
                            "product": widget.productUsed.text,
                            "comment": widget.comment.text,
                            "cost": double.parse(widget.cost.text),
                            "activityType": _selectedActivityType['id'],
                            "activityDate": widget._dateController.text,
                          };

                          var request;
                          if (widget._initialData != null) {
                            body['id'] = widget._initialData['id'];
                            body['farmId'] = widget._initialData['farmId'];
                            request = ApiBase.instance.requests.updateActivity
                                .execute(context, body: body);
                          } else {
                            body['farmId'] = _selectedFarm['id'];
                            request = ApiBase.instance.requests.createActivity
                                .execute(context, body: body);
                          }
                          request.then((val) {
                            if (val != null) {
                              Navigator.of(context).pop();
                            }
                          });
                        },
                        child: Text("Save"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  void _selectDate(TextEditingController controller) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1980),
        lastDate: DateTime(2100));

    if (picked != null) {
      String day = "${picked.day.toString().padLeft(2, "0")}";
      String month = "${picked.month.toString().padLeft(2, "0")}";
      String year = "${picked.year % 100}";
      controller.text = "$month/$day/$year";
    }
  }
}
