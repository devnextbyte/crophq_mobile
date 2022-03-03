import 'dart:convert';
import 'dart:io';

import 'package:crophq/ChTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//convert to stateless widget
// get token and print
class Weather extends StatefulWidget {
  final String location;
  Weather(this.location){
    //print("$location");
  }
  @override
  State<StatefulWidget> createState() {
    return _WeatherState();
  }
}

class _WeatherState extends State<Weather> {
  final String _tokenKey = "_WeatherStateTokenKey";
  final String _expireKey = "_WeatherStateExpireKey";

  DateTime _contextDate = DateTime.now();
  List<dynamic> _allData;
  int hour = DateTime.now().hour;

  @override
  void initState() {
    super.initState();
    showLoading();
    syncDataWithDate().whenComplete(() {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Weather"),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                setState(() {
                  hour = DateTime.now().hour;
                });
              },
              icon: Icon(Icons.settings_backup_restore),
            ),
          ],
        ),
        body: _allData == null
            ? Container()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    getCurrentTemp(),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _allData.map((data) {
                          return getSmallCard(data, _allData.indexOf(data));
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ));
  }

  Widget getDateTime() {
    TextStyle _style = ChTextStyle.heading;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "${_contextDate.month}".padLeft(2, "0"),
              style: _style,
            ),
            Text(
              "/${_contextDate.day}".padLeft(2, "0"),
              style: _style,
            ),
            Text(
              "/${_contextDate.year}".padLeft(2, "0"),
              style: _style,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              getAmPmHour(hour),
              style: _style,
            ),
            Text(
              " TO ",
              style: _style,
            ),
            Text(
              getAmPmHour(hour + 1),
              style: _style,
            ),
          ],
        )
      ],
    );
  }

  String getAmPmHour(int localhour) {
    String amPm = localhour > 12 ? "PM" : "AM";
    String genhour = localhour > 12 ? "${localhour - 12}" : "$localhour";
    genhour = genhour.padLeft(2, "0");
    return "$genhour $amPm";
  }

  Widget getCurrentTemp() {
    return Column(
      children: <Widget>[
        getDateTime(),
        Row(
          children: <Widget>[
            Expanded(flex: 2, child: getLeftColumn(context, _allData[hour])),
            Expanded(flex: 3, child: getRightColumn(_allData[hour])),
          ],
        ),
      ],
    );
  }

  Widget getSmallCard(_data, index) {
    String amPm = index > 12 ? 'PM' : 'AM';
    int hour = index > 12 ? index - 12 : index;
    if(hour == 0 ){
      hour = 12;
    }
    final precp = _data['precipitation'];
    return GestureDetector(
      onTap: () {
        setState(() {
          hour = index;
        });
      },
      child: Card(
        elevation: 6,
        color: hour == index ? Theme.of(context).accentColor : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: <Widget>[
            Text(
              "$hour $amPm",
              style: ChTextStyle.primaryBold,
            ),
            Padding(padding: EdgeInsets.only(top: 6)),
            Text(
              "${precp['chance'].toStringAsFixed(0)}%",
              style: ChTextStyle.primaryText,
              textAlign: TextAlign.end,
            ),
            Padding(padding: EdgeInsets.only(top: 2)),
            Text(
              "${_data['temperatures']['value'].toStringAsFixed(2)} ${_data['temperatures']['units']}",
              style: ChTextStyle.primaryText,
            ),
          ]),
        ),
      ),
    );
  }

  Widget getLeftColumn(BuildContext context, _data) {
    final temp = _data['soilTemperatures'];
    final moist = _data['soilMoisture'];
    final baseColor = Theme.of(context).accentColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("SOIL", style: ChTextStyle.heading),
        getSoilCard(temp[0], moist[0], baseColor.withAlpha(100)),
        getSoilCard(temp[1], moist[1], baseColor.withAlpha(150)),
        getSoilCard(temp[2], moist[2], baseColor.withAlpha(200)),
        getSoilCard(temp[3], moist[3], baseColor.withAlpha(255)),
      ],
    );
  }

  Widget getSoilCard(dynamic temp, dynamic moist, Color color) {
    String below = "${temp['depth']}";
    return Card(
      margin: EdgeInsets.only(top: 4),
      elevation: 4,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("${temp['average'].toStringAsFixed(1)}${temp['units']}",
                      style: ChTextStyle.primaryBold),
                  Text("moisture: ${moist['average'].toStringAsFixed(2)}",
                      style: ChTextStyle.primaryText.copyWith(fontSize: 10))
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text("${below.substring(0, below.length - 13)}",
                    style: ChTextStyle.secondaryText.copyWith(
                      color: Colors.white,
                      fontSize: 6,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getRightColumn(_data) {
    final precp = _data['precipitation'];
    final w = _data['wind'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          "${_data['temperatures']['value'].toStringAsFixed(2)} ${_data['temperatures']['units']}",
          style: ChTextStyle.heading.copyWith(fontSize: 40),
        ),
        Container(
          width: 120,
          child: Text("${_data['conditionsText']}",
              style: ChTextStyle.primaryText, textAlign: TextAlign.end),
        ),
        Text(
          "${precp['chance'].toStringAsFixed(2)}%   ${precp['amount'].toStringAsFixed(2)} ${precp['units']} Precipitation",
          style: ChTextStyle.primaryText,
        ),
        Text(
            "${_data['relativeHumidity']['average'].toStringAsFixed(2)} Humidity"),
        Text(
            "${w['average'].toStringAsFixed(2)}${w['units']}, ${w['bearing'].toStringAsFixed(2)}${w['direction']} Wind"),
      ].map((w) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: w,
        );
      }).toList(),
    );
  }

  Future<void> syncDataWithDate() async {
    String token = await getToken();
    if (token.isEmpty) {
      showError("Failed to retrieve token, please try again later");
      return;
    }
    print(token);
    String date =
        "${_contextDate.year}-${_contextDate.month}-${_contextDate.day}";
    final requestString =
        "https://api.awhere.com/v2/weather/locations/${widget.location}/forecasts/$date";
    final response = await http.get(
      requestString,
      headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
    );
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _allData = json.decode(response.body)['forecast'];
      });
    } else if (response.statusCode == 401) {
      showError("Failed to retrieve data, please try again later");
      return;
    } else {
      String errorString = "";

      final errorData = json.decode(response.body??"{}")??{};

      final errors = [
        "Request: $requestString",
        "${errorData["statusCode"]??"Nil"}",
        "${errorData["detailedMessage"]??"${response.body}"}",
      ];
      
      errors.forEach((err){
        errorString += err;
        errorString += "\n";

      });
      //print("$errorString");

      showError("$errorString");
    }
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(_tokenKey) ?? "";

    if (token.isNotEmpty) {
      //getting current time in
      final currentTimeInSec =
          (DateTime.now().millisecondsSinceEpoch / 1000).ceil();
      //currentTime > expire time, set token to empty
      if (currentTimeInSec > prefs.getInt(_expireKey)) {
        token = "";
      }
    }

    if (token.isEmpty) {
      final response = await http.post(
        "https://api.awhere.com/oauth/token",
        body: {"grant_type": "client_credentials"},
        headers: {
          HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader:
              "Basic QTNTUWJEMWxnWDdLMXBRWFY0WnhPV2JBMG9zSklRUlg6VVlORmVnRUdxaDBEempTRw=="
        },
      );
      if (response.statusCode == 200) {
        final responseObj = json.decode(response.body);
        await prefs.setString(_tokenKey, responseObj['access_token']);

        //get expire time and add current time in sec to it
        //subtract 10 sec to avoid on the time expire
        await prefs.setInt(
          _expireKey,
          responseObj['expires_in'] +
              (DateTime.now().millisecondsSinceEpoch / 1000).ceil() -
              10,
        );
        return responseObj['access_token'];
      } else {
        return "";
      }
    } else {
      return token;
    }
  }

  Widget getWeatherIcon(String text) {
    return Column(
      children: <Widget>[Icon(Icons.wb_sunny), Text(text)],
    );
  }

  Widget getDailyWeather() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        getWeatherIcon("4 PM"),
        getWeatherIcon("8 PM"),
        getWeatherIcon("12 AM"),
        getWeatherIcon("4 AM"),
        getWeatherIcon("8 AM"),
        getWeatherIcon("12 PM"),
      ],
    );
  }

  Widget getWeekWeather() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        getWeatherIcon("Today"),
        getWeatherIcon("Sat"),
        getWeatherIcon("Sun"),
        getWeatherIcon("Mon"),
        getWeatherIcon("Tue"),
        getWeatherIcon("Wed"),
      ],
    );
  }

  void showError(String error) {
    Future.delayed(Duration.zero, () {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(error),
            );
          });
    });
  }

  void showLoading() {
    Future.delayed(Duration.zero, () {
      showDialog(
          context: context,
          builder: (builder) {
            return AlertDialog(
              content: Row(
                children: <Widget>[
                  CircularProgressIndicator(),
                  Padding(padding: EdgeInsets.only(left: 24)),
                  Text("Loading")
                ],
              ),
            );
          });
    });
  }
}
