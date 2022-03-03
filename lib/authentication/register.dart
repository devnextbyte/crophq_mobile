import 'package:crophq/api_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'confirmation.dart';

class Register extends StatefulWidget {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _town = TextEditingController();

  @override
  State<StatefulWidget> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  List<dynamic> _countries; // = [];
  List<dynamic> _cities; // = [];
  dynamic _selectedCity;
  dynamic _selectedCountry;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ApiBase.instance.requests.getAllCities.execute(context).then((response) {
        if (response != null) {
          setState(() {
            _countries = response['data'];
            _selectedCountry = _countries[0];
            _cities = _countries[0]["regions"];
            _selectedCity = _cities[0];
            //print("country set");
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //print("rebuild");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: "Full Name",
                ),
                keyboardType: TextInputType.text,
                controller: widget._fullName,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              TextField(
                controller: widget._email,
                decoration: InputDecoration(
                  labelText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              TextField(
                controller: widget._phoneNumber,
                decoration: InputDecoration(
                  labelText: "Phone",
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              TextField(
                controller: widget._password,
                decoration: InputDecoration(
                  labelText: "Password",
                ),
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                obscureText: true,
              ),
              TextField(
                controller: widget._confirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              Padding(padding: EdgeInsets.only(top: 8)),
              Text(
                "Country",
                textAlign: TextAlign.start,
              ),
              _countries != null && _countries.length > 0
                  ? DropdownButton(
                      isExpanded: true,
                      items: _countries.map((countryObj) {
                        return DropdownMenuItem(
                          value: countryObj,
                          child: Text(countryObj["country"]),
                        );
                      }).toList(),
                      value: _selectedCountry,
                      onChanged: (val) {
                        setState(() {
                          _selectedCountry = val;
                          _cities = val['regions'];
                          _selectedCity = _cities[0];
                        });
                      },
                    )
                  : Divider(),
              Text("Region"),
              _cities != null && _cities.length > 0
                  ? DropdownButton(
                      isExpanded: true,
                      items: _cities.map(
                        (cityObj) {
                          return DropdownMenuItem(
                            value: cityObj,
                            child: Text(cityObj['region']),
                          );
                        },
                      ).toList(),
                      value: _selectedCity,
                      onChanged: (selectedCityObj) {
                        setState(() {
                          _selectedCity = selectedCityObj;
                        });
                      },
                    )
                  : Divider(),
              TextField(
                controller: widget._town,
                decoration: InputDecoration(
                  labelText: "Town",
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Builder(
                      builder: (ctx) => RaisedButton(
                        onPressed: () {
                          if (widget._fullName.text.isEmpty ||
                              widget._email.text.isEmpty ||
                              widget._phoneNumber.text.isEmpty ||
                              widget._password.text.isEmpty ||
                              widget._town.text.isEmpty ||
                              widget._confirmPassword.text.isEmpty) {
                            Scaffold.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text("Please fill all fields"),
                              ),
                            );
                          } else if (widget._password.text !=
                              widget._confirmPassword.text) {
                            Scaffold.of(ctx).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Confirm password does not match"),
                              ),
                            );
                          } else if (!widget._phoneNumber.text
                              .startsWith("+")) {
                            Scaffold.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Please also mention country code with number (eg. +1xxxxxxxx)."),
                              ),
                            );
                          } else if (_selectedCity['id'] == -1) {
                            Scaffold.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text("Select Region"),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (c) => Confirmation(
                                  registerData: {
                                    "fullName": widget._fullName.text,
                                    "email": widget._email.text,
                                    "phoneNumber": widget._phoneNumber.text,
                                    "password": widget._password.text,
                                    "confirmPassword":
                                        widget._confirmPassword.text,
                                    "town": widget._town.text,
                                    "regionId": _selectedCity['id']
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        child: Text("Next"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
