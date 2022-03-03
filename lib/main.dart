import 'package:crophq/api_base.dart';
import 'package:crophq/authentication/login.dart';
import 'package:crophq/dashboard.dart';
import 'package:flutter/material.dart';

import 'ChColors.dart';
import 'farm/add_farm.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropHq',
      home: Splash(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xff016638,
          <int, Color>{
            50: Color(0xFFE8F5E9),
            100: Color(0xFFC8E6C9),
            200: Color(0xFFA5D6A7),
            300: Color(0xFF81C784),
            400: Color(0xFF66BB6A),
            500: Color(0xff016638),
            600: Color(0xFF43A047),
            700: Color(0xFF388E3C),
            800: Color(0xFF2E7D32),
            900: Color(0xFF1B5E20),
          },
        ),
        // primaryColor: Color.fromARGB(255, 1, 103, 56),
        accentColor: Color.fromARGB(255, 153, 135, 115),
        fontFamily: "montserrat",
        // floatingActionButtonTheme: FloatingActionButtonThemeData(
        //     backgroundColor: Color.fromARGB(255, 1, 103, 56)),
        // colorScheme: ColorScheme.light(
        //   primary: Color.fromARGB(255, 153, 135, 115),
        // ),
        buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.primary,
            height: 48,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            )),
      ),
    );
  }
}

class TempHold {
  bool first = true;
}

class Splash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashState();
  }
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      openNext(context);
    });
  }

  void openNext(BuildContext context) async {
    await ApiBase.instance.requests.getAllCities.reloadList(context);
    final loggedIn = await ApiBase.instance.tokenHandler.isLoggedIn(context);
    if (!loggedIn) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
    } else {
      // print("loggedin");
      Map<String, dynamic> response =
          await ApiBase.instance.requests.getFarms.execute(
        context,
        loadingActive: false,
        body: {"Page": 1, "PageSize": 100},
      );
      if (response == null) {
        return;
      }
      // print("resp $response");
      final List<dynamic> data = response["data"];
      if (data.length > 0) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Dashboard()));
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddFarm(
              firstEntry: true,
            ),
          ),
        );
        openNext(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: ChColors.background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("assets/vertical_logo.jpg"),
          ),
        ),
      ),
    );
  }
}
