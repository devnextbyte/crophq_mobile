import 'package:crophq/api_base.dart';
import 'package:crophq/community/posts.dart';
import 'package:crophq/farm/farm_list.dart';
import 'package:crophq/farm_record/farm_record_list.dart';
import 'package:crophq/post_scouting/map_pest_scouting.dart';
import 'package:crophq/profile.dart';
import 'package:crophq/weather/select_weather_farm.dart';
import 'package:flutter/material.dart';

import 'ChTextStyle.dart';
import 'crop_health/select_farm_ch.dart';

//Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
//  print("bg message handler");
//  if (message.containsKey('data')) {
//    // Handle data message
//    // final dynamic data = message['data'];
//    print("data");
//  }
//
//  if (message.containsKey('notification')) {
//    // Handle notification message
//    // final dynamic notification = message['notification'];
//    print("notification");
//  }
//}

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
//    final fcm = FirebaseMessaging();
//    fcm.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        print("onMessage: $message");
//        // _showItemDialog(message);
//        showDialog(
//          context: null,
//          builder: (context) => AlertDialog(
//            content: ListTile(
//              title: Text(message['notification']['title']),
//              subtitle: Text(message['notification']['body']),
//            ),
//            actions: <Widget>[
//              FlatButton(
//                child: Text('Ok'),
//                onPressed: () => Navigator.of(context).pop(),
//              ),
//            ],
//          ),
//        );
//      },
//      onBackgroundMessage: myBackgroundMessageHandler,
//      onLaunch: (Map<String, dynamic> message) async {
//        print("onLaunch: $message");
//        // _navigateToItemDetail(message);
//      },
//      onResume: (Map<String, dynamic> message) async {
//        print("onResume: $message");
//        // _navigateToItemDetail(message);
//      },
//    );
//
//    fcm.subscribeToTopic('all');
//    fcm.requestNotificationPermissions(IosNotificationSettings(
//      sound: true,
//      badge: true,
//      alert: true,
//    ));
//    fcm.getToken().then((token) {
//      print("$token");
//      Future.delayed(Duration.zero, () {
//        ApiBase.instance.requests.changeFcm
//            .execute(context, loadingActive: false, body: {
//          "deviceType": 1,
//          "fcmId": token,
//        }).then((v) {
//          if (v != null) {
//            print("change fcm request response $v ");
//          }
//        });
//      });
//    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        centerTitle: true,
        actions: <Widget>[
          
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Profile()));
            },
            icon: Icon(Icons.person_outline),
          ),
          IconButton(
            onPressed: () {
              ApiBase.instance.tokenHandler.logout(context);
            },
            icon: Icon(Icons.lock_outline),
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: EdgeInsets.all(16),
        children: <Widget>[
          getDashboardButton(context, Icons.cloud, "Weather", () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SelectWeatherFarm()));
          }),
          getDashboardButton(context, Icons.map, "Crop Health Maps", () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => SelectFarmCh()));
          }),
          getDashboardButton(
              context, Icons.bug_report, "Pest and Disease Scouting", () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MapPestScouting()));
          }),
          getDashboardButton(context, Icons.local_florist, "Register My Farms",
              () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => FarmList()));
          }),
          getDashboardButton(context, Icons.line_style, "My Farm Records", () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FarmRecordList()));
          }),
          getDashboardButton(context, Icons.people, "CropHQ Community", () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Posts()));
          }),
        ],
      ),
    );
  }

  Widget getDashboardButton(
      BuildContext context, IconData icon, String title, Function onPress) {
    return GestureDetector(
      onTap: onPress,
      child: Card(
        elevation: 8,
        clipBehavior: Clip.hardEdge,
        color: Theme.of(context).primaryColor,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            Expanded(
                child: Text(
              title,
              style: ChTextStyle.primaryBold.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ))
          ],
        ),
      ),
    );
  }
}
