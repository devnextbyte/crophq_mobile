import 'dart:convert';
import 'dart:io';

import 'package:crophq/api_base.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  final password = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  String _imageUrl;
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
//    print("loading image");
    Future.delayed(Duration.zero, () {
      ApiBase.instance.requests.getUserProfileGet.execute(context, body: {
      }).then((val) {
        //print("val $val");
        if (val != null) {
          _imageUrl = val['data']['image'];
          setState(() {
            _imageUrl = "${ApiBase.instance.requests.systemIp}$_imageUrl";
            print(_imageUrl);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:_key,
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(80.0),
                    child: Container(
                      color: Colors.grey.shade300,
                      height: 160,
                      width: 160,
                      child: (_imageUrl == null || _imageUrl.isEmpty)
                          ? Icon(Icons.person, size: 80)
                          : Image.network(
                              _imageUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    onPressed: () async {
                      _key.currentState.showBottomSheet(
                            (ctx) =>
                            Container(
                              child: new Wrap(
                                children: <Widget>[
                                  new ListTile(
                                    leading: new Icon(Icons.camera),
                                    title: new Text('Camera'),
                                    onTap: () =>
                                        _getImage(ImageSource.camera),
                                  ),
                                  new ListTile(
                                    leading: new Icon(Icons.image),
                                    title: new Text('Gallery'),
                                    onTap: () =>
                                        _getImage(ImageSource.gallery),
                                  ),
                                ],
                              ),
                            ),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      );
                    },
                    child: Text("Update Image"),
                  ),
                ],
              ),
              Text("Change Password"),
              Divider(),
              TextField(
                decoration: InputDecoration(labelText: "Enter your password"),
                controller: widget.password,
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              TextField(
                decoration: InputDecoration(labelText: "New password"),
                controller: widget.newPassword,
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              TextField(
                  decoration: InputDecoration(labelText: "Confirm password"),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  controller: widget.confirmPassword),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Builder(
                    builder: (ctx) => RaisedButton(
                      onPressed: () {
                        ApiBase.instance.requests.changePassword
                            .execute(context, body: {
                          "currentPassword": widget.password.text,
                          "newPassword": widget.newPassword.text,
                          "confirmPassword": widget.confirmPassword.text
                        }).then((val) {
                          if (val != null) {
                            Scaffold.of(ctx).showSnackBar(
                                SnackBar(content: Text("Password changed")));
                            ApiBase.instance.tokenHandler.logout(context);
                          }
                        });
                      },
                      child: Text("Change password"),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future _getImage(ImageSource source) async {
    Navigator.of(context).pop();
    //print("getimage");
    var image = await ImagePicker().getImage(source: source, maxHeight: 200);

    await ApiBase.instance.requests.updateImage.execute(
        context,
        body: {"image": base64Encode(File(image.path).readAsBytesSync())});
    _loadProfile();
  }

//  Future<File> _getImage() async {
//    File image =
//        await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 200);
//    return image;
//  }
}
