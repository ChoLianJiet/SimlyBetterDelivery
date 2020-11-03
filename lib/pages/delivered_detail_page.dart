//Dart import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//Third party library import
import 'package:google_fonts/google_fonts.dart';

//Local import
import 'package:simply_better_delivery/state_management/main.dart';
import 'package:simply_better_delivery/model/to_deliver_item.dart';
import 'package:simply_better_delivery/pages/widgets/undeliver_delivery_dialog.dart';
import 'package:simply_better_delivery/pages/widgets/complete_delivery_dialog.dart';

class DeliveredDetailPage extends StatefulWidget {
  MainStateManager manager;
  WaypointDetail waypointDetail;

  DeliveredDetailPage({@required this.manager, @required this.waypointDetail});

  @override
  State<StatefulWidget> createState() {
    return _DeliveredDetailPageState();
  }
}

class _DeliveredDetailPageState extends State<DeliveredDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            Navigator.pop(context);
            return;
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              title: Text(
                'Delivered Details',
                style: GoogleFonts.quicksand(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: widget.waypointDetail.completedDate == null
                              ? Colors.orange
                              : widget.waypointDetail.deliveredSuccessfully ==
                                      null
                                  ? Colors.orange
                                  : widget.waypointDetail.deliveredSuccessfully
                                      ? Colors.green
                                      : Colors.red,
                          width: 2),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: width,
                              child: Text(
                                widget.waypointDetail.receiver.name,
                                style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Container(
                              width: width * 0.6,
                              child: Text(
                                widget.waypointDetail.receiver.contactNumber,
                                style: GoogleFonts.quicksand(fontSize: 12.5),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: width * 0.6,
                              child: Text(
                                widget.waypointDetail.address.address,
                                style: GoogleFonts.quicksand(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
//                            Container(
//                              width: width * 0.7,
//                              child: Text(
//                                'Delivery ID: ${widget.toDeliverItem.deliveryId}',
//                                style: GoogleFonts.quicksand(fontSize: 10),
//                              ),
//                            ),
                          ],
                        ),
                        Positioned(
                          right: 5,
                          top: 5,
                          child: widget.waypointDetail.completedDate == null
                              ? Text(
                                  'On Going',
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.orange),
                                )
                              : widget.waypointDetail.deliveredSuccessfully ==
                                      null
                                  ? Text(
                                      'On Going',
                                      style: GoogleFonts.quicksand(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.orange),
                                    )
                                  : widget.waypointDetail.deliveredSuccessfully
                                      ? Text(
                                          'Completed',
                                          style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.green),
                                        )
                                      : Text(
                                          'Undelivered',
                                          style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.red),
                                        ),
                        ),
                      ],
                    ),
                  ),
                  widget.waypointDetail.completedDate == null
                      ? Container()
                      : widget.waypointDetail.deliveredSuccessfully == null
                          ? Container()
                          : widget.waypointDetail.deliveredSuccessfully
                              ? Container(
                                  margin: EdgeInsets.only(
                                      left: 10, right: 10, bottom: 10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.green, width: 2),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: width,
                                        child: Text(
                                          'Earned',
                                          style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        width: width * 0.6,
                                        child: Text(
                                          widget.waypointDetail.earned == null
                                              ? 'Calculating'
                                              : 'RM ${widget.waypointDetail.earned.toStringAsFixed(2)}',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      widget.waypointDetail.earned == null
                                          ? Container()
                                          : SizedBox(
                                              height: 5,
                                            ),
                                      widget.waypointDetail.earned == null
                                          ? Container()
                                          : Container(
                                              width: width,
                                              child: Text(
                                                'Claimed',
                                                style: GoogleFonts.quicksand(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                            ),
                                      widget.waypointDetail.earned == null
                                          ? Container()
                                          : Container(
                                              width: width * 0.6,
                                              child: Text(
                                                widget.waypointDetail.claimed
                                                    ? 'Yes'
                                                    : 'Not yet',
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                )
                              : Container(
                                  margin: EdgeInsets.only(
                                      left: 10, right: 10, bottom: 10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.red, width: 2),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: width,
                                        child: Text(
                                          'Undelivered Reason',
                                          style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        width: width * 0.6,
                                        child: Text(
                                          widget.waypointDetail.failedReason ==
                                                  ''
                                              ? 'N/A'
                                              : widget
                                                  .waypointDetail.failedReason,
                                          style: GoogleFonts.quicksand(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: width,
                          child: Text(
                            'Order List',
                            style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ListView.builder( shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),itemBuilder: (BuildContext context, int index){
                          String deliveryId = widget.waypointDetail
                              .toDeliverItemList[index].deliveryId;
                          Map<String, Map<String, ToDeliverItemDetail>>
                          chilledOrRoomTemperatureProductMap = {
                            'frozen': {},
                            'chilled': {},
                            'room': {},
                          };
                          widget.waypointDetail.toDeliverItemList[index]
                              .orderList
                              .forEach((String productId,
                              ToDeliverItemDetail
                              toDeliveryItemDetail) {
                            if (toDeliveryItemDetail.frozen) {
                              chilledOrRoomTemperatureProductMap['frozen']
                                  .addAll(
                                  {productId: toDeliveryItemDetail});
                            } else if (toDeliveryItemDetail.chilled) {
                              chilledOrRoomTemperatureProductMap['chilled']
                                  .addAll(
                                  {productId: toDeliveryItemDetail});
                            } else {
                              chilledOrRoomTemperatureProductMap['room']
                                  .addAll(
                                  {productId: toDeliveryItemDetail});
                            }
                          });
                        return Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                          Text('Delivery ID: $deliveryId',
                            style: GoogleFonts.quicksand(fontSize: 12.5,    fontWeight:
                            FontWeight.w800,),),
                          chilledOrRoomTemperatureProductMap['room'].isEmpty
                              ? Container()
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Room Temperature',
                                style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17.5),
                              ),
                              ListView.builder(
                                padding: EdgeInsets.only(bottom: 10),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int i) {
                                  String productId =
                                  chilledOrRoomTemperatureProductMap[
                                  'room']
                                      .keys
                                      .toList()[i];
                                  ToDeliverItemDetail toDeliverItemDetail =
                                  chilledOrRoomTemperatureProductMap[
                                  'room'][productId];
                                  return Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${i + 1})',
                                        style: GoogleFonts.quicksand(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              toDeliverItemDetail
                                                  .productName,
                                              style: GoogleFonts.quicksand(
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 15),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(
                                                          10)),
                                                  child: Container(
                                                    width: 100,
                                                    height: 100,
                                                    child: Image.network(
                                                      toDeliverItemDetail
                                                          .productImages
                                                          .first,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                    NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (BuildContext
                                                    context,
                                                        int l) {
                                                      String option =
                                                      toDeliverItemDetail
                                                          .options.keys
                                                          .toList()[l];
                                                      num quantity =
                                                          toDeliverItemDetail
                                                              .options[
                                                          option]
                                                              .quantity;
                                                      return Container(
                                                          margin: EdgeInsets
                                                              .only(
                                                              bottom:
                                                              2),
                                                          child: Text(
                                                            '$option x$quantity',
                                                            style: GoogleFonts
                                                                .quicksand(
                                                                fontSize:
                                                                12.5),
                                                          ));
                                                    },
                                                    itemCount:
                                                    toDeliverItemDetail
                                                        .options.length,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                itemCount:
                                chilledOrRoomTemperatureProductMap[
                                'room']
                                    .length,
                              ),
                            ],
                          ),
                          chilledOrRoomTemperatureProductMap['chilled'].isEmpty
                              ? Container()
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chilled',
                                style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17.5),
                              ),
                              ListView.builder(
                                padding: EdgeInsets.only(bottom: 10),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int i) {
                                  String productId =
                                  chilledOrRoomTemperatureProductMap[
                                  'chilled']
                                      .keys
                                      .toList()[i];
                                  ToDeliverItemDetail toDeliverItemDetail =
                                  chilledOrRoomTemperatureProductMap[
                                  'chilled'][productId];
                                  return Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${i + 1})',
                                        style: GoogleFonts.quicksand(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              toDeliverItemDetail
                                                  .productName,
                                              style: GoogleFonts.quicksand(
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 15),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(
                                                          10)),
                                                  child: Container(
                                                    width: 100,
                                                    height: 100,
                                                    child: Image.network(
                                                      toDeliverItemDetail
                                                          .productImages
                                                          .first,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                    NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (BuildContext
                                                    context,
                                                        int l) {
                                                      String option =
                                                      toDeliverItemDetail
                                                          .options.keys
                                                          .toList()[l];
                                                      num quantity =
                                                          toDeliverItemDetail
                                                              .options[
                                                          option]
                                                              .quantity;
                                                      return Container(
                                                          margin: EdgeInsets
                                                              .only(
                                                              bottom:
                                                              2),
                                                          child: Text(
                                                            '$option x$quantity',
                                                            style: GoogleFonts
                                                                .quicksand(
                                                                fontSize:
                                                                12.5),
                                                          ));
                                                    },
                                                    itemCount:
                                                    toDeliverItemDetail
                                                        .options.length,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                itemCount:
                                chilledOrRoomTemperatureProductMap[
                                'chilled']
                                    .length,
                              ),
                            ],
                          ),
                          chilledOrRoomTemperatureProductMap['frozen'].isEmpty
                              ? Container()
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Frozen',
                                style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17.5),
                              ),
                              ListView.builder(
                                padding: EdgeInsets.only(bottom: 10),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int i) {
                                  String productId =
                                  chilledOrRoomTemperatureProductMap[
                                  'frozen']
                                      .keys
                                      .toList()[i];
                                  ToDeliverItemDetail toDeliverItemDetail =
                                  chilledOrRoomTemperatureProductMap[
                                  'frozen'][productId];
                                  return Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${i + 1})',
                                        style: GoogleFonts.quicksand(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              toDeliverItemDetail
                                                  .productName,
                                              style: GoogleFonts.quicksand(
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 15),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(
                                                          10)),
                                                  child: Container(
                                                    width: 100,
                                                    height: 100,
                                                    child: Image.network(
                                                      toDeliverItemDetail
                                                          .productImages
                                                          .first,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                    NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (BuildContext
                                                    context,
                                                        int l) {
                                                      String option =
                                                      toDeliverItemDetail
                                                          .options.keys
                                                          .toList()[l];
                                                      num quantity =
                                                          toDeliverItemDetail
                                                              .options[
                                                          option]
                                                              .quantity;
                                                      return Container(
                                                          margin: EdgeInsets
                                                              .only(
                                                              bottom:
                                                              2),
                                                          child: Text(
                                                            '$option x$quantity',
                                                            style: GoogleFonts
                                                                .quicksand(
                                                                fontSize:
                                                                12.5),
                                                          ));
                                                    },
                                                    itemCount:
                                                    toDeliverItemDetail
                                                        .options.length,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                itemCount:
                                chilledOrRoomTemperatureProductMap[
                                'frozen']
                                    .length,
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                        ],);
                      },      itemCount:
                        widget.waypointDetail.toDeliverItemList.length,)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
