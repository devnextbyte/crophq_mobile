import 'package:crophq/api_base.dart';
import 'package:flutter/material.dart';

class RequestCropHealth extends StatefulWidget {
  final _plantingDate = TextEditingController();
  final _harvestDate = TextEditingController();
  final _farmObj;

  RequestCropHealth(this._farmObj);

  @override
  State<StatefulWidget> createState() {
    return _RequestCropHealthState();
  }
}

class _RequestCropHealthState extends State<RequestCropHealth> {
  var _crops = List<dynamic>();

  dynamic _selectedCrop;

  List<dynamic> _cropCategories; // = [];
//  List<dynamic> _crops; // = [];

  dynamic _selectedCropCategory;

//  dynamic _selectedCrop;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final crops =
          await ApiBase.instance.requests.getAllCrops.execute(context);
      if (crops == null) {
        return;
      }
      setState(() {
        _cropCategories = crops['data'];
        if (_cropCategories != null && _cropCategories.length > 0) {
          _selectedCropCategory = _cropCategories[0];
          _crops = _selectedCropCategory["crops"];
          if (_crops != null && _crops.length > 0) {
            _selectedCrop = _crops[0];
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String farmName = widget._farmObj['name'];
    return Scaffold(
      appBar: AppBar(
        title: Text("Request Crop Health Map"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Farm: $farmName"),
              Text("Select Crop"),
              SizedBox(
                height: 16,
              ),
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
                                            }
                                            print(
                                                "selected crop : ${_crops.toString()}");
                                          });
                                        },
                                        value: _selectedCropCategory,
                                        items: _cropCategories.map((category) {
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
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextField(
                controller: widget._plantingDate,
                onTap: () {
                  _selectDate(widget._plantingDate);
                },
                readOnly: true,
                decoration: InputDecoration(labelText: "Planting Date"),
              ),
              TextField(
                controller: widget._harvestDate,
                onTap: () {
                  _selectDate(widget._harvestDate);
                },
                readOnly: true,
                decoration:
                    InputDecoration(labelText: "Actual/Expected Harvest Date"),
              ),
              Padding(padding: EdgeInsets.only(top: 32)),
              Builder(
                builder: (ctx) => RaisedButton(
                  onPressed: () {
                    if (_selectedCrop == null ||
                        widget._harvestDate.text.isEmpty ||
                        widget._plantingDate.text.isEmpty) {
                      Scaffold.of(ctx).showSnackBar(SnackBar(
                        content: Text("Enter all values"),
                      ));
                      return;
                    }

                    ApiBase.instance.requests.createFarmRequest
                        .execute(context, body: {
                      "farmId": widget._farmObj['id'],
                      "cropId": _selectedCrop['id'],
                      "plantingDate": widget._plantingDate.text,
                      "harvestDate": widget._harvestDate.text
                    }).then((v) async {
                      if (v != null) {
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                actions: <Widget>[
                                  FlatButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      })
                                ],
                                content: Text(
                                    "Your request has been submitted successfully, we will get back to you with available crop health maps"),
                              );
                            });
                        Navigator.of(context).pop();
                      }
                    });
                  },
                  child: Text("Request"),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
