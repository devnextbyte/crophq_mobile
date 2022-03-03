import 'package:crophq/api_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ChTextStyle.dart';

class ViewPost extends StatefulWidget {
  final _post;
  final _commentText = TextEditingController();
  ViewPost(this._post);

  @override
  State<StatefulWidget> createState() {
    return _ViewPostState();
  }
}

class _ViewPostState extends State<ViewPost> {
  List<dynamic> _comments = List();
  var followingPost = false;

  @override
  void initState() {
    super.initState();
    _loadComment();
  }

  IconButton getFollowButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (followingPost) {
          ApiBase.instance.requests.unFollowPost.execute(context,
              pathVar: {"postId": widget._post['id']}).then((v) {
            loadPostStatus(context);
          });
        } else {
          ApiBase.instance.requests.followPost.execute(context,
              pathVar: {"postId": widget._post['id']}).then((v) {
            loadPostStatus(context);
          });
        }
        // loadPostStatus(context);
      },
      icon: Icon(
          followingPost ? Icons.notifications_off : Icons.notifications_active),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("View Post"),
          actions: <Widget>[
            getFollowButton(context),
            // IconButton(
            //   onPressed: () {
            //     Navigator.of(context).push(MaterialPageRoute(
            //       builder: (context) => AddPost(
            //         initialData: widget._post,
            //       ),
            //     ));
            //   },
            //   icon: Icon(Icons.edit),
            // ),
            IconButton(
              onPressed: () {
                final id = widget._post['id'];
                ApiBase.instance.requests.deletePost.execute(context, pathVar: {
                  "id": "$id",
                }).then((val) {
                  if (val != null) {
                    Navigator.of(context).pop();
                  }
                });
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                getPostCard(widget._post, context),
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Column(
                    children: _comments.map((f) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                f['name'],
                                style: ChTextStyle.primaryText
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              Material(
                                child: InkWell(
                                  customBorder: CircleBorder(),
                                  onTap: () {
                                    final id = f['id'];
                                    ApiBase.instance.requests.deleteComment
                                        .execute(context, pathVar: {
                                      "id": "$id",
                                    }).then((val) {
                                      if (val != null) {
                                        _loadComment();
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.delete),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            f['comment'],
                            style: ChTextStyle.primaryText,
                          ),
                          Padding(padding: EdgeInsets.only(top: 16)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                Card(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: widget._commentText,
                            decoration:
                                InputDecoration(labelText: "Enter comment"),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.send,
                          ),
                          onPressed: _addComment,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void _addComment() async {
    Future.delayed(Duration.zero, () {
      ApiBase.instance.requests.addComment.execute(context, body: {
        "postId": widget._post['id'],
        "comment": widget._commentText.text,
      }).then((val) {
        if (val != null) {
          widget._commentText.text = "";
          _loadComment();
        }
      });
    });
  }

  Future<void> loadPostStatus(BuildContext context) async {
    final posts = await ApiBase.instance.requests.getFollowedPosts.execute(
      context,
      body: {
        "Page": 1,
        "PageSize": 20,
      },
    );
    if (posts != null) {
      setState(() {
        followingPost = false;
      });
      posts['data'].forEach((post) {
        if (post['id'] == widget._post['id']) {
          setState(() {
            followingPost = true;
          });
        }
      });
    }
  }

  void _loadComment() async {
    Future.delayed(
      Duration.zero,
      () async {
        await loadPostStatus(context);
        ApiBase.instance.requests.loadComments.execute(
          context,
          body: {
            "PostId": widget._post['id'],
            "Page": 1,
            "PageSize": 20,
          },
        ).then(
          (val) {
            if (val != null) {
              setState(() {
                _comments = val['data'];
              });
            }
          },
        );
      },
    );
  }

  Widget getPostCard(post, BuildContext context) {
    List<String> tags = List();
    for (final tag in post['tags']) {
      tags.add("$tag");
    }
    return Card(
      child: Container(
        padding: EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(post['poster']),
            Divider(),
            Text(
              post['title'],
              style: ChTextStyle.primaryBold,
            ),
            Text(
              post['description'],
              style: ChTextStyle.primaryText,
            ),
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
