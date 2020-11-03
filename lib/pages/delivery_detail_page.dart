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

class DeliveryDetailPage extends StatefulWidget {
  MainStateManager manager;
  WaypointDetail waypointDetail;
  int index;

  DeliveryDetailPage(
      {@required this.manager,
      @required this.waypointDetail,
      @required this.index});

  @override
  State<StatefulWidget> createState() {
    return _DeliveryDetailPageState();
  }
}

class _DeliveryDetailPageState extends State<DeliveryDetailPage> {
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
                'Delivery Details',
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
                  Hero(
                    flightShuttleBuilder: (
                      BuildContext flightContext,
                      Animation<double> animation,
                      HeroFlightDirection flightDirection,
                      BuildContext fromHeroContext,
                      BuildContext toHeroContext,
                    ) {
                      return SingleChildScrollView(
                        child: fromHeroContext.widget,
                      );
                    },
                    tag: 'delivery_detail_${widget.index}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        margin:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
                            Container(
                              width: width * 0.7,
                              child:   Text(
                                'No. of delivery ID: ${ widget.waypointDetail.deliveryIdList.length}', style:
                              GoogleFonts.quicksand(
                                  fontSize: 10),),
                            ),
                          ],
                        ),
                      ),
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
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
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
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Delivery ID: $deliveryId',
                                  style: GoogleFonts.quicksand(fontSize: 12.5,    fontWeight:
                                  FontWeight.w800,),),
                                chilledOrRoomTemperatureProductMap['room']
                                        .isEmpty
                                    ? Container()
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Room Temperature',
                                            style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17.5),
                                          ),
                                          ListView.builder(
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemBuilder:
                                                (BuildContext context,
                                                    int i) {
                                              String productId =
                                                  chilledOrRoomTemperatureProductMap[
                                                          'room']
                                                      .keys
                                                      .toList()[i];
                                              ToDeliverItemDetail
                                                  toDeliverItemDetail =
                                                  chilledOrRoomTemperatureProductMap[
                                                      'room'][productId];
                                              return Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${i + 1})',
                                                    style:
                                                        GoogleFonts.quicksand(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                            fontSize: 15),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          toDeliverItemDetail
                                                              .productName,
                                                          style: GoogleFonts
                                                              .quicksand(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      15),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                              child:
                                                                  Container(
                                                                width: 100,
                                                                height: 100,
                                                                child: Image
                                                                    .network(
                                                                  toDeliverItemDetail
                                                                      .productImages
                                                                      .first,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              child: ListView
                                                                  .builder(
                                                                shrinkWrap:
                                                                    true,
                                                                physics:
                                                                    NeverScrollableScrollPhysics(),
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int l) {
                                                                  String
                                                                      option =
                                                                      toDeliverItemDetail
                                                                          .options
                                                                          .keys
                                                                          .toList()[l];
                                                                  num quantity = toDeliverItemDetail
                                                                      .options[
                                                                          option]
                                                                      .quantity;
                                                                  return Container(
                                                                      margin: EdgeInsets.only(
                                                                          bottom:
                                                                              2),
                                                                      child:
                                                                          Text(
                                                                        '$option x$quantity',
                                                                        style:
                                                                            GoogleFonts.quicksand(fontSize: 12.5),
                                                                      ));
                                                                },
                                                                itemCount:
                                                                    toDeliverItemDetail
                                                                        .options
                                                                        .length,
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
                                chilledOrRoomTemperatureProductMap['chilled']
                                        .isEmpty
                                    ? Container()
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Chilled',
                                            style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17.5),
                                          ),
                                          ListView.builder(
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemBuilder:
                                                (BuildContext context,
                                                    int i) {
                                              String productId =
                                                  chilledOrRoomTemperatureProductMap[
                                                          'chilled']
                                                      .keys
                                                      .toList()[i];
                                              ToDeliverItemDetail
                                                  toDeliverItemDetail =
                                                  chilledOrRoomTemperatureProductMap[
                                                      'chilled'][productId];
                                              return Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${i + 1})',
                                                    style:
                                                        GoogleFonts.quicksand(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                            fontSize: 15),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          toDeliverItemDetail
                                                              .productName,
                                                          style: GoogleFonts
                                                              .quicksand(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      15),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                              child:
                                                                  Container(
                                                                width: 100,
                                                                height: 100,
                                                                child: Image
                                                                    .network(
                                                                  toDeliverItemDetail
                                                                      .productImages
                                                                      .first,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              child: ListView
                                                                  .builder(
                                                                shrinkWrap:
                                                                    true,
                                                                physics:
                                                                    NeverScrollableScrollPhysics(),
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int l) {
                                                                  String
                                                                      option =
                                                                      toDeliverItemDetail
                                                                          .options
                                                                          .keys
                                                                          .toList()[l];
                                                                  num quantity = toDeliverItemDetail
                                                                      .options[
                                                                          option]
                                                                      .quantity;
                                                                  return Container(
                                                                      margin: EdgeInsets.only(
                                                                          bottom:
                                                                              2),
                                                                      child:
                                                                          Text(
                                                                        '$option x$quantity',
                                                                        style:
                                                                            GoogleFonts.quicksand(fontSize: 12.5),
                                                                      ));
                                                                },
                                                                itemCount:
                                                                    toDeliverItemDetail
                                                                        .options
                                                                        .length,
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
                                chilledOrRoomTemperatureProductMap['frozen']
                                        .isEmpty
                                    ? Container()
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Frozen',
                                            style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17.5),
                                          ),
                                          ListView.builder(
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemBuilder:
                                                (BuildContext context,
                                                    int i) {
                                              String productId =
                                                  chilledOrRoomTemperatureProductMap[
                                                          'frozen']
                                                      .keys
                                                      .toList()[i];
                                              ToDeliverItemDetail
                                                  toDeliverItemDetail =
                                                  chilledOrRoomTemperatureProductMap[
                                                      'frozen'][productId];
                                              return Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${i + 1})',
                                                    style:
                                                        GoogleFonts.quicksand(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                            fontSize: 15),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          toDeliverItemDetail
                                                              .productName,
                                                          style: GoogleFonts
                                                              .quicksand(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      15),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                              child:
                                                                  Container(
                                                                width: 100,
                                                                height: 100,
                                                                child: Image
                                                                    .network(
                                                                  toDeliverItemDetail
                                                                      .productImages
                                                                      .first,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              child: ListView
                                                                  .builder(
                                                                shrinkWrap:
                                                                    true,
                                                                physics:
                                                                    NeverScrollableScrollPhysics(),
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int l) {
                                                                  String
                                                                      option =
                                                                      toDeliverItemDetail
                                                                          .options
                                                                          .keys
                                                                          .toList()[l];
                                                                  num quantity = toDeliverItemDetail
                                                                      .options[
                                                                          option]
                                                                      .quantity;
                                                                  return Container(
                                                                      margin: EdgeInsets.only(
                                                                          bottom:
                                                                              2),
                                                                      child:
                                                                          Text(
                                                                        '$option x$quantity',
                                                                        style:
                                                                            GoogleFonts.quicksand(fontSize: 12.5),
                                                                      ));
                                                                },
                                                                itemCount:
                                                                    toDeliverItemDetail
                                                                        .options
                                                                        .length,
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
                              ],
                            );
                          },
                          itemCount:
                              widget.waypointDetail.toDeliverItemList.length,
                        )
                      ],
                    ),
                  ),
                  widget.index == 0
                      ? Container(
                          margin:
                              EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          padding: EdgeInsets.all(10),
                          width: width * 0.6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipOval(
                                child: Material(
                                  color: Colors.transparent, // bu// tton color
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.red, width: 2),
                                        shape: BoxShape.circle),
                                    child: InkWell(
                                      splashColor: Theme.of(context)
                                          .splashColor, // inkwell color
                                      child: SizedBox(
                                          width: 35,
                                          height: 35,
                                          child: Icon(
                                            Icons.clear,
                                            color: Colors.red,
                                          )),
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return UndeliverDeliveryDialog(
                                                manager: widget.manager,
                                                waypointDetail:
                                                    widget.waypointDetail,
                                              );
                                            });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              ClipOval(
                                child: Material(
                                  color: Colors.transparent, // bu// tton color
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.green, width: 2),
                                        shape: BoxShape.circle),
                                    child: InkWell(
                                      splashColor: Theme.of(context)
                                          .splashColor, // inkwell color
                                      child: SizedBox(
                                          width: 35,
                                          height: 35,
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          )),
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CompleteDeliveryDialog(
                                                manager: widget.manager,
                                                waypointDetail:
                                                    widget.waypointDetail,
                                              );
                                            });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
