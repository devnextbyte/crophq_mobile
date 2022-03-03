import 'package:crophq/api_base.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatelessWidget {
  final token;
  final newPin = TextEditingController();
  final confirmPin = TextEditingController();
  ResetPassword(this.token);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Reset Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: "Enter new password"),
              controller: newPin,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Confirm new password"),
              controller: confirmPin,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Builder(
                    builder: (ctx) => RaisedButton(
                      child: Text("Reset"),
                      onPressed: () {
                        if (newPin.text != confirmPin.text) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("Password doesn't match with confirm password")));
                          return;
                        }
                        token['password'] = newPin.text;
                        ApiBase.instance.requests.forgetPassNewPass
                            .execute(context, body: token)
                            .then((val) {
                          if (val != null) {
                            Navigator.of(context).pop();
                          }
                        });
                      },
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
