//Dart import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

//Third party library import
import 'package:cloud_firestore/cloud_firestore.dart';

//Local import
import 'package:simply_better_delivery/state_management/main.dart';

class StartDeliveryDialog extends StatefulWidget {
  MainStateManager manager;
  QuerySnapshot querySnapshot;

  StartDeliveryDialog({@required this.manager,@required this.querySnapshot});

  @override
  State<StatefulWidget> createState() {
    return _StartDeliveryDialogState();
  }
}

class _StartDeliveryDialogState extends State<StartDeliveryDialog> {
  bool _startDeliveryLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return _startDeliveryLoading
        ? AlertDialog(
            contentPadding: EdgeInsets.all(10),
            content: Container(
                width: 50,
                height: 50,
                child: Center(
                    child: Container(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator()))),
          )
        : AlertDialog(
            title: Text('Start Delivery',style: GoogleFonts.quicksand(),),
            content: Text('Start delivery now?',style: GoogleFonts.quicksand(),),
            actions: [
              FlatButton(
                child: Text('No',style: GoogleFonts.quicksand(),),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Yes',style: GoogleFonts.quicksand(),),
                onPressed: () async {
                  setState(() {
                    _startDeliveryLoading = true;
                  });
                  await widget.manager.startToDeliver(widget.querySnapshot).whenComplete(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
  }
}
