//Dart import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

//Third party library import

//Local import
import 'package:simply_better_delivery/state_management/main.dart';
import 'package:simply_better_delivery/model/to_deliver_item.dart';

class CompleteDeliveryDialog extends StatefulWidget {
  MainStateManager manager;
  WaypointDetail waypointDetail;

  CompleteDeliveryDialog({@required this.manager,@required this.waypointDetail});

  @override
  State<StatefulWidget> createState() {
    return _CompleteDeliveryDialogState();
  }
}

class _CompleteDeliveryDialogState extends State<CompleteDeliveryDialog> {
  bool _completeDeliveryLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return _completeDeliveryLoading
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
      title: Text('Complete Delivery',style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),),
      content: Text('Are you sure you want to complete this delivery?'),
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
              _completeDeliveryLoading = true;
            });
            await widget.manager.completeDelivery(widget.waypointDetail).whenComplete(() {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          },
        ),
      ],
    );
  }
}
