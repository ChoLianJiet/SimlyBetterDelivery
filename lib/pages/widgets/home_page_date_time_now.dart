//Dart import
import 'package:flutter/material.dart';
import 'dart:async';

//Third party library import
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

//Local import
import 'package:simply_better_delivery/state_management/main.dart';

class HomePageDateTimeNowText extends StatefulWidget {
  MainStateManager manager;

  HomePageDateTimeNowText({@required this.manager});

  @override
  State<StatefulWidget> createState() {
    return _HomePageDateTimeNowTextState();
  }
}

class _HomePageDateTimeNowTextState extends State<HomePageDateTimeNowText> {
  Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormat('dd MMM yyyy').format(_now),
          style: GoogleFonts.quicksand(fontSize: 30, color: Color(0xffCCC9DF)),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(
            DateFormat('HH:mm:ss').format(_now),
            style:
                GoogleFonts.quicksand(fontSize: 15, color: Color(0xffCCC9DF)),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
