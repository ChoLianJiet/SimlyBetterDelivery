//Dart import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

//Third party library import

//Local import
import 'package:simply_better_delivery/state_management/main.dart';
import 'package:simply_better_delivery/model/to_deliver_item.dart';

class UndeliverDeliveryDialog extends StatefulWidget {
  MainStateManager manager;
  WaypointDetail waypointDetail;

  UndeliverDeliveryDialog({@required this.manager,@required this.waypointDetail});

  @override
  State<StatefulWidget> createState() {
    return _UndeliverDeliveryDialogState();
  }
}

class _UndeliverDeliveryDialogState extends State<UndeliverDeliveryDialog> {
  bool _undeliverDeliveryLoading = false;
  TextEditingController _textEditingController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return _undeliverDeliveryLoading
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
      title: Text('Undeliver Delivery',style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),),
      content: TextField(
        maxLines: 4,
        controller: _textEditingController,
        decoration: InputDecoration(
            hintText: 'Reason',
          hintStyle: GoogleFonts.quicksand(),
        ),
        style: GoogleFonts.quicksand(),
      ),
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
              _undeliverDeliveryLoading = true;
            });
            await widget.manager.undeliverDelivery(widget.waypointDetail, _textEditingController.text).whenComplete(() {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          },
        ),
      ],
    );
  }
}
