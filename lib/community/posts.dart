
import 'package:crophq/ChTextStyle.dart';
import 'package:crophq/api_base.dart';
import 'package:crophq/community/addpost.dart';
import 'package:crophq/community/viewpost.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Posts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PostState();
  }
}

class _PostState extends State<Posts> {
  var _posts = List<dynamic>();

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  void _loadList() {
    Future.delayed(Duration.zero, () {
      ApiBase.instance.requests.posts
          .execute(context, body: {"Page": 1, "PageSize": 20}).then((onValue) {
        if (onValue != null) {
          setState(() {
            _posts = onValue['data'];
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
        title: Text("Posts"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddPost()));
          _loadList();
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: _posts.map((post) {
            return GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ViewPost(post)));
                _loadList();
              },
              child: getPostCard(post, context),
            );
          }).toList(),
        ),
      ),
    );
  }

  Card getPostCard(post, BuildContext context) {
    List<String> tags = List();
    for (final tag in post['tags']) {
      tags.add("$tag");
    }
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(post['poster']),
            Divider(),
            Text(
              post['title'],
              style: ChTextStyle.primaryBold,
            ),
            Text(post['description'],
              style: ChTextStyle.primaryText,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: tags.map((tag) {
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  padding: EdgeInsets.all(4),
                  child: Text(
                    tag,
                    style: ChTextStyle.secondaryText,
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
