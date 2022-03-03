import 'package:crophq/api_base.dart';
import 'package:crophq/crop_health/request_crop_helth.dart';
import 'package:flutter/material.dart';

class ViewCropHealth extends StatefulWidget {
  final _farmObj;

  ViewCropHealth(this._farmObj);

  @override
  State<StatefulWidget> createState() {
    return _ViewCropHealthState();
  }
}

class _ViewCropHealthState extends State<ViewCropHealth> {
  List<dynamic> _images = List();

  @override
  void initState() {
    super.initState();
    //print("view crop health page");
    Future.delayed(Duration.zero, () {
      ApiBase.instance.requests.getFarmHeatImages.execute(context, body: {
        "FarmId": widget._farmObj['id'],
        "Page": 1,
        "PageSize": 100,
      }).then((v) {
        //print("response $v");
        if (v != null) {
          setState(() {
            _images = v['data'] ?? List();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crop Health Maps"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => RequestCropHealth(widget._farmObj)));
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _images != null && _images.length > 0
            ? ListView(
                children: _images.map((imageLink) {
                  //print("${ApiBase.systemIp}${imageLink['image']}");
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Image.network(
                      "${ApiBase.systemIp}${imageLink['image']}",
                      fit: BoxFit.contain,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Color.fromARGB(255, 1, 103, 56),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              )
            : Center(
                child: Text(
                  "No image found",
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
      ),
    );
  }
}
