import 'package:flutter/material.dart';

class AddWeather extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AddWeather"),
      ),
      body: SingleChildScrollView(
              child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: "Name",
                ),
                keyboardType: TextInputType.text,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Mobile",
                ),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                ),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Region",
                ),
                keyboardType: TextInputType.text,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Country",
                ),
                keyboardType: TextInputType.text,
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Send"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
