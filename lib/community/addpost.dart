import 'package:crophq/api_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddPost extends StatefulWidget {
  final _initialData;
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _tags = TextEditingController();

  AddPost({initialData}) : _initialData = initialData {
    if (_initialData != null) {
      _title.text = _initialData['title'];
      _description.text = _initialData['description'];
      _tags.text = _initialData['tags'].reduce((val, comp) {
        return "$val, $comp";
      });
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _AddPostState();
  }
}

class _AddPostState extends State<AddPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Post"),
      ),
      body: getAddPostFarm(context),
    );
  }

  Widget getAddPostFarm(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: "Title"),
            controller: widget._title,
          ),
          TextField(
            decoration: InputDecoration(labelText: "Description"),
            controller: widget._description,
          ),
          TextField(
            decoration: InputDecoration(labelText: "Comma seperated tags"),
            controller: widget._tags,
          ),
          RaisedButton(
            child: Text("Save"),
            onPressed: () {
              final body = {
                "title": widget._title.text,
                "description": widget._description.text,
                "tags": widget._tags.text.split(",")
              };
              var request;
              if (widget._initialData != null) {
                int id = widget._initialData['id'];
                request = ApiBase.instance.requests.updatePost.execute(
                  context,
                  pathVar: {"id": "$id"},
                  body: body,
                );
              } else {
                request = ApiBase.instance.requests.createPost.execute(
                  context,
                  body: body,
                );
              }

              request.then((val) {
                if (val != null) {
                  Navigator.of(context).pop();
                }
              });
            },
          )
        ],
      ),
    );
  }
}
