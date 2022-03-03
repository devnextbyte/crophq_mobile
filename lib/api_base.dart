import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crophq/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiBase {
  static final String systemIp = "https://api.crophq.nextbytesolutions.com";
  static final instance = ApiBase();
  final requests = _Requests();
  final tokenHandler = _TokenHandler();
}

enum _Type { GET, PUT, POST, DELETE }

void showLoading(BuildContext context) {
  AlertDialog alert = AlertDialog(
      // title: Text("Loading"),
      content: Row(
    children: <Widget>[
      CircularProgressIndicator(),
      Padding(padding: EdgeInsets.only(left: 24)),
      Text("Loading")
    ],
  ));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void showError(BuildContext context, String message) {
  AlertDialog alert = AlertDialog(
    title: Text("Error"),
    content: Text(message ?? "An unexpected error has occured"),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class _CachedRequest extends _Request {
  _CachedRequest(String route, bool requireAuth, _Type type)
      : super(route, requireAuth, type);

  Future<dynamic> reloadList(
    BuildContext context, {
    Map<String, dynamic> body,
    loadingActive = true,
    Map<String, String> pathVar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    //print("loading data");
    final newData = await super.execute(context,
        body: body, loadingActive: loadingActive, pathVar: pathVar);
    //print("saving data");
    await prefs.setString(super._route, json.encode(newData));
    //print("return new data");
    return newData;
  }

  @override
  Future<dynamic> execute(
    BuildContext context, {
    Map<String, dynamic> body,
    loadingActive = true,
    Map<String, String> pathVar,
    filePath = "",
  }) async {
    //print("Cahced running at ${super._route}");
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(super._route);
    if (data != null && data.isNotEmpty) {
      //print("returning cache data");
      return json.decode(data);
    } else {
      return await reloadList(context,
          body: body, loadingActive: loadingActive, pathVar: pathVar);
    }
  }
}

class _Requests {
  static final String _baseUrl = "${ApiBase.systemIp}/api/v1";

  final systemIp = ApiBase.systemIp;

  final exchange = _Request(
      "${ApiBase.systemIp}/connect/token", false, _Type.POST,
      contentType: "application/x-www-form-urlencoded");
  final getAllCities = _CachedRequest("$_baseUrl/Region/all", false, _Type.GET);
  final sendSms =
      _Request("$_baseUrl/PhoneVerify/sendVerificationCode", false, _Type.POST);
  final verifyNumber =
      _Request("$_baseUrl/PhoneVerify/verifyPhoneNumber", false, _Type.POST);
  final registerCustomer = _Request("$_baseUrl/Customer", false, _Type.POST);
  final getAllCrops = _Request("$_baseUrl/Crop/all", true, _Type.GET);

  final createFarm = _Request("$_baseUrl/Farm", true, _Type.POST);
  final updateFarm = _Request("$_baseUrl/Farm", true, _Type.PUT);
  final getFarms = _Request("$_baseUrl/Farm", true, _Type.GET);

  final addFarmImage = _Request("$_baseUrl/FarmImage", true, _Type.POST);
  final getFarmImage = _Request("$_baseUrl/FarmImage", true, _Type.GET);
  final deleteFarm = _Request("$_baseUrl/Farm/:FarmId", true, _Type.DELETE);

  final getFarmHeatImages = _Request("$_baseUrl/FarmHeatMap", true, _Type.GET);
  final createFarmRequest = _Request("$_baseUrl/FarmRequest", true, _Type.POST);
  final getPests = _Request("$_baseUrl/Pest/all", true, _Type.GET);
  final loadComments = _Request("$_baseUrl/Comment", true, _Type.GET);
  final addComment = _Request("$_baseUrl/Comment", true, _Type.POST);
  final deleteComment = _Request("$_baseUrl/Comment/:id", true, _Type.DELETE);
  final updatePost = _Request("$_baseUrl/Post/:id", true, _Type.PUT);
  final deletePost = _Request("$_baseUrl/Post/:id", true, _Type.DELETE);
  final createPost = _Request("$_baseUrl/Post", true, _Type.POST);
  final posts = _Request("$_baseUrl/Post", true, _Type.GET);
  final createActivity = _Request("$_baseUrl/FarmActivity", true, _Type.POST);
  final updateActivity = _Request("$_baseUrl/FarmActivity", true, _Type.PUT);
  final deleteActivity =
      _Request("$_baseUrl/FarmActivity/:id/Farm/:farmId", true, _Type.DELETE);
  final activities = _Request("$_baseUrl/FarmActivity", true, _Type.GET);
  final activitiesPdf = _Request("$_baseUrl/FarmActivity/pdf", true, _Type.GET);

  final addPestScouting = _Request("$_baseUrl/PestScouting", true, _Type.POST);
  final getScoutings = _Request("$_baseUrl/PestScouting", true, _Type.GET);

  final updateProfile = _Request("$_baseUrl/User/profile", true, _Type.POST);
  final getUserProfile =
      _Request("$_baseUrl/User/getByRoleAndPhone", true, _Type.POST);
  final getUserProfileGet =
  _Request("$_baseUrl/User/profile", true, _Type.GET);
  final updateImage = _Request("$_baseUrl/User/image", true, _Type.POST);
  final changePassword =
      _Request("$_baseUrl/User/changePassword", true, _Type.POST);

  final forgetPassword =
      _Request("$_baseUrl/User/forgetPassword", false, _Type.POST);
  final forgetPassConfirmOtp =
      _Request("$_baseUrl/User/verifyOtpPin", false, _Type.POST);
  final forgetPassNewPass =
      _Request("$_baseUrl/User/setPasswordByToken", false, _Type.POST);

  final changeFcm = _Request("$_baseUrl/User/fcm", true, _Type.POST);

  final getFollowedPosts = _Request("$_baseUrl/PostFollower", true, _Type.GET);
  final followPost =
      _Request("$_baseUrl/PostFollower/follow/:postId", true, _Type.PUT);
  final unFollowPost =
      _Request("$_baseUrl/PostFollower/unFollow/:postId", true, _Type.PUT);
}

class _Request {
  final String _route;
  final bool _requireAuth;
  final _Type _type;
  final String _contentType;

  _Request(this._route, this._requireAuth, this._type,
      {String contentType = "application/json"})
      : _contentType = contentType;

  String _mapToParams(Map<String, dynamic> map) {
    var args = "";
    if (map != null) {
      var count = 0;
      for (String key in map.keys) {
        final val = map[key];
        args += "$key=$val";
        count++;
        if (count < map.keys.length) {
          args += "&";
        }
      }
      return args;
    } else {
      return "";
    }
  }

  Future<dynamic> execute(
    BuildContext context, {
    Map<String, dynamic> body,
    loadingActive = true,
    Map<String, String> pathVar,
    filePath = "",
  }) async {
    // print(body);
    String localRoute = _route;
    if (pathVar != null) {
      // print(pathVar.keys);
      for (String key in pathVar.keys) {
        localRoute = localRoute.replaceAll(":$key", pathVar[key]);
        //print("new $localRoute");
      }
    }
    //print("$localRoute");

    bool showingLoading = false;
    try {
      if (loadingActive) {
        showLoading(context);
        showingLoading = true;
      }
      http.Response response;
      final header = {HttpHeaders.contentTypeHeader: _contentType};

      if (_requireAuth) {
        String token = await _TokenHandler().getToken(context);
        header[HttpHeaders.authorizationHeader] = "Bearer $token";
      }
      if (_type == _Type.GET) {
        String args = _mapToParams(body);
        response = await http.get("$localRoute?$args", headers: header);
      }
      if (_type == _Type.PUT) {
        response = await http.put(localRoute,
            body: body != null
                ? (_contentType == "application/json"
                    ? json.encode(body)
                    : body)
                : "",
            headers: header);
      } else if (_type == _Type.POST) {
        print(body);
        response = await http.post(
          localRoute,
          body: body != null
              ? (_contentType == "application/json" ? json.encode(body) : body)
              : "",
          headers: header,
        );
      } else if (_type == _Type.DELETE) {
        String args = _mapToParams(body);
        response = await http.delete("$localRoute?$args", headers: header);
      }
      if (showingLoading) {
        Navigator.pop(context);
        showingLoading = false;
      }
      print(response.statusCode);
       print(response.body);
      if (response.statusCode == 200) {
        if (filePath.isNotEmpty) {
//          final fl = await File(filePath).writeAsBytes(response.bodyBytes);
          //print("${fl.path}");
          return "";
        } else {
          return json.decode(response.body);
        }
      } else if (response.statusCode == 204) {
        //print("Error 204");
        return "";
      } else if (response.statusCode == 401) {
        showError(context, "Unauthorise, try to logout and login again");
        //print("Error 401");
        return null;
      } else {
        print(json.decode(response.body));
        String errorMessage = json.decode(response.body)["error_description"];

        if (errorMessage == null || errorMessage.isEmpty) {
          final errResp = json.decode(response.body);
          errorMessage = errResp["message"];
          final errors = errResp['errors'];
          if (errors != null) {
            errors.forEach((err) {
              errorMessage += "\n";
              errorMessage += err;
            });
          }
          final String exception = errResp['exception'];
          if (exception != null) {
            errorMessage += "\n";
            errorMessage += exception;
          }
        }
        //print("Error $errorMessage");

        showError(context, errorMessage);
        return null;
      }
    } catch (e) {
      if (showingLoading) {
        Navigator.pop(context);
      }

      showError(context, "Unexpected Error\n$e");
      print(e);
      return null;
    }
  }
}

class _TokenHandler {
  final _tokenKey = "tokenKey";
  final _expireTimeKey = "expireTimeKey";

  Future<void> setToken(Map<String, dynamic> raw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, json.encode(raw));
    int expiresIn = raw['expires_in'];
    await prefs.setDouble(
      _expireTimeKey,
      DateTime.now().millisecondsSinceEpoch + (expiresIn.toDouble() * 1000),
    );
    return;
  }

  Future<bool> isLoggedIn(BuildContext context) async {
    String token = await _getRawToken(context);
    return token.isNotEmpty;
  }

  Future<String> _getRawToken(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final rawToken = prefs.getString(_tokenKey) ?? "";
    if (rawToken.isEmpty) {
      return "";
    }
    final expireAt = prefs.getDouble(_expireTimeKey) ?? 0;
    if (expireAt == 0) {
      showError(context,
          ".......................Something went wrong. Please login again.");
      await logout(context);
      return "";
    }
    if (expireAt <= DateTime.now().millisecondsSinceEpoch) {
      try {
        String refreshToken = json.decode(rawToken)["refresh_token"];
        final response = await http.post(
          _Requests().exchange._route,
          body: {
            "granttype": "refresh_token",
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
          },
          headers: {
            HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded"
          },
        );
        if (response.statusCode == 200) {
          Map<String, dynamic> newToken = json.decode(response.body);
          newToken["refresh_token"] = refreshToken;
          setToken(newToken);
          return response.body;
        } else {
          showError(context,
              "Something went wrong on server side. Please login again.");
          await logout(context);
          return "";
        }
      } catch (err) {
        print(err);
        showError(context, "Something went wrong. Please login again.");
        await logout(context);
        return "";
      }
    } else {
      return rawToken;
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, "");
    await prefs.setDouble(
      _expireTimeKey,
      0,
    );
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Splash()),
        ModalRoute.withName('/'));
  }

  Future<String> getToken(BuildContext context) async {
    String token = await _getRawToken(context);
    if (token.isEmpty) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => Splash()),
          ModalRoute.withName('/'));
      logout(context);
      return "";
    }
    Map<String, dynamic> tokenJson = json.decode(token);
    return tokenJson['access_token'];
  }
}
