import 'package:crophq/api_base.dart';
import 'package:crophq/authentication/resetPassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crophq/main.dart';

import '../ChTextStyle.dart';

class Confirmation extends StatefulWidget {
  final Map<String, dynamic> _data;
  final String _phoneNumber;
  final _verificationInput = TextEditingController();
  Confirmation({Map<String, dynamic> registerData, String phoneNumber})
      : _data = registerData,
        _phoneNumber = phoneNumber;
  @override
  State<StatefulWidget> createState() {
    return _ConfirmationState();
  }
}

class _ConfirmationState extends State<Confirmation> {
  bool phoneConfirmed = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (widget._data != null) {
        String phoneNumber = widget._data["phoneNumber"];
        ApiBase.instance.requests.sendSms.execute(
          context,
          body: {
            "phoneNumber": "$phoneNumber",
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Confirmation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: getEnterOtpColumn(context),
      ),
    );
  }

  Column getEnterOtpColumn(BuildContext context) {
    String phoneNumber = widget._data != null
        ? widget._data["phoneNumber"]
        : widget._phoneNumber;
    return Column(
      children: <Widget>[
        Text(
            "Confirmation Text has been sent to $phoneNumber. Please enter the recieved OTP.",
            textAlign: TextAlign.center,
            style: ChTextStyle.primaryBold),
        Padding(padding: EdgeInsets.only(top: 16)),
        TextField(
          decoration: InputDecoration(
            labelText: "Phone verification code",
          ),
          keyboardType: TextInputType.number,
          controller: widget._verificationInput,
        ),
        Padding(padding: EdgeInsets.only(top:16)),
        Row(
          children: <Widget>[
            Expanded(
                          child: Builder(
                builder: (ctx) => RaisedButton(
                  onPressed: () {
                    String otp = widget._verificationInput.text;
                    if (otp.isEmpty || otp.length < 4 || otp.length > 4) {
                      Scaffold.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text("Please enter 4 digit OTP"),
                        ),
                      );
                    } else {
                      if (widget._data != null) {
                        registerUser(context); //.then((val) {});
                      } else {
                        confirmForRest(context);
                      }
                    }
                  },
                  child: Text("Done"),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> confirmForRest(BuildContext context) async {
    final val = await ApiBase.instance.requests.forgetPassConfirmOtp.execute(
      context,
      body: {
        "mobileNumber": widget._phoneNumber,
        "otp": widget._verificationInput.text,
      },
    );

    if (val == null) {
      return;
    }

    final verificationData = {
      "token": val['token']['result'],
      "userId": val['Id']
    };
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => ResetPassword(verificationData)),
    );
  }

  Future<void> registerUser(BuildContext context) async {
    //print("ConfirationLog: register user");
    var val = await ApiBase.instance.requests.verifyNumber.execute(
      context,
      body: {
        "phoneNumber": widget._data["phoneNumber"],
        "code": widget._verificationInput.text
      },
    );
    if (val == null) {
      return;
    }
    //print("ConfirationLog: verify val not null");

    val = await ApiBase.instance.requests.registerCustomer.execute(
      context,
      body: widget._data,
    );

    if (val == null) {
      return;
    }
    //print("ConfirationLog: register val not null");
    final data = widget._data;
    print(data);

    ApiBase.instance.requests.exchange.execute(context, body: {
      "username": data["phoneNumber"],
      "password": data["password"],
      "grant_type": "password",
      "granttype": "password",
      "scope": "openid email profile offline_access roles",
      "Role": "Customer"
    }).then((val) {
      if (val != null) {
        ApiBase.instance.tokenHandler.setToken(val);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => Splash()),
            ModalRoute.withName('/'));
      }
    });
  }
}
