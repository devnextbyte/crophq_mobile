import 'package:crophq/ChColors.dart';
import 'package:crophq/api_base.dart';
import 'package:crophq/authentication/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ChTextStyle.dart';
import '../main.dart';
import 'confirmation.dart';

class Login extends StatelessWidget {
  final phone = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Login"),
      ),
      body: Container(
        color: ChColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 24)),
              Image.asset("assets/vertical_logo.jpg"),
              TextField(
                decoration: InputDecoration(
                  labelText: "Phone Number",
                ),
                keyboardType: TextInputType.phone,
                controller: phone,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Password",
                ),
                keyboardType: TextInputType.text,
                obscureText: true,
                controller: password,
              ),
              Padding(padding: EdgeInsets.only(top: 16)),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Builder(
                      builder: (ctx) => RaisedButton(
                        
                        onPressed: () {
                          if (phone.text.isEmpty || password.text.isEmpty) {
                            Scaffold.of(ctx).showSnackBar(SnackBar(
                                content: Text("Please fill all fields")));
                            return;
                          }
                          ApiBase.instance.requests.exchange
                              .execute(context, body: {
                            "username": phone.text,
                            "password": password.text,
                            "grant_type": "password",
                            "granttype": "password",
                            "scope":
                                "openid email profile offline_access roles",
                            "role": "Customer",
                          }).then((val) async {
                            if (val != null) {
                              await ApiBase.instance.tokenHandler.setToken(val);
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          Splash()),
                                  ModalRoute.withName('/'));
                            }
                          });
                        },
                        child: Text("Login"),
                      ),
                    ),
                  ),
                ],
              ),
              // Padding(
              //   padding: EdgeInsets.only(top: 8),
              // ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Register()));
                },
                child: Text("Register"),
              ),
              Padding(
                padding: EdgeInsets.only(top: 40),
              ),
              Builder(
                builder: (ctx) => FlatButton(
                  onPressed: () {
                    if (phone.text.isNotEmpty) {
                      ApiBase.instance.requests.forgetPassword
                          .execute(context, body: {
                        "mobileNumber": phone.text,
                      }).then((val) {
                        if (val != null) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Confirmation(
                              phoneNumber: phone.text,
                            ),
                          ));
                        }
                      });
                    } else {
                      Scaffold.of(ctx).showSnackBar(
                          SnackBar(content: Text("Enter phone number")));
                    }
                  },
                  child: Text(
                    "Forgot Password?",
                    style: ChTextStyle.secondaryText,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
