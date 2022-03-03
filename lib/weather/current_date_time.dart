import 'package:crophq/ChTextStyle.dart';
import 'package:flutter/cupertino.dart';

class CurrentDateTime extends StatefulWidget {
  final TextStyle _style = ChTextStyle.heading;
  @override
  State<StatefulWidget> createState() {
    return _CurrentDateTimeState();
  }
}

class _CurrentDateTimeState extends State<CurrentDateTime> {
  DateTime current = DateTime.now();

  void startUpdateRecurr() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        current = DateTime.now();
      });
      startUpdateRecurr();
    });
  }

  @override
  void initState() {
    super.initState();
    startUpdateRecurr();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "${current.month}".padLeft(2, "0"),
          style: widget._style,
        ),
        Text(
          "/${current.day}".padLeft(2, "0"),
          style: widget._style,
        ),
        Text(
          "/${current.year}".padLeft(2, "0"),
          style: widget._style,
        ),
        Text(
          " ",
          style: widget._style,
        ),
        Text(
          "${current.hour > 12 ? current.hour - 12 : current.hour}"
              .padLeft(2, "0"),
          style: widget._style,
        ),
        Container(
          width: 12,
          padding: EdgeInsets.only(bottom: 2),
          child: Center(
            child: Text(
              "${current.second % 2 == 0 ? ':' : ' '}",
              style: widget._style,
            ),
          ),
        ),
        Text(
          "${current.minute}".padLeft(2, "0"),
          style: widget._style,
        ),
        Text(
          " ",
          style: widget._style,
        ),
        Text(
          "${current.hour > 12 ? 'PM' : 'AM'}",
          style: widget._style,
        ),
      ],
    );
  }
}
