//Dart import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//Third party library import
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Local import
import 'package:simply_better_delivery/state_management/main.dart';
import 'package:simply_better_delivery/model/to_deliver_item.dart';
import 'package:simply_better_delivery/model/total_item.dart';

class CheckDeliveriesPage extends StatefulWidget {
  MainStateManager manager;
  QuerySnapshot querySnapshot;

  CheckDeliveriesPage({@required this.manager, @required this.querySnapshot});

  @override
  State<StatefulWidget> createState() {
    return _CheckDeliveriesPageState();
  }
}

class _CheckDeliveriesPageState extends State<CheckDeliveriesPage>
    with SingleTickerProviderStateMixin {
  final List<Tab> _tabs = <Tab>[
    Tab(
      icon: Icon(Icons.format_list_bulleted),
      text: 'Total',
    ),
    Tab(
      icon: Icon(Icons.directions_car),
      text: 'Delivery',
    ),
  ];
  TabController _tabController;
  PageController _pageController;

  List<WaypointDetail> _waypointDetailList = [];
  TotalItem _totalItem = TotalItem(productMap: {});

  @override
  void initState() {
    _tabController = TabController(length: _tabs.length, vsync: this);
    _pageController = PageController(initialPage: _tabController.index);

    _pageController = PageController(initialPage: _tabController.index);
    _pageController.addListener(() {
      if (_pageController.page.round() != _tabController.index) {
        setState(() {
          _tabController.index = _pageController.page.round();
        });
      }
    });
    widget.querySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
      documentSnapshot.data['waypoints'].forEach((dynamic waypointDetails) {
        if (waypointDetails['completed_date'] == null) {
          _waypointDetailList.add(WaypointDetail.fromFirestore(
              documentSnapshot.documentID, waypointDetails));
        }
      });
    });

    print(_waypointDetailList);

    _waypointDetailList.forEach((WaypointDetail waypointDetail) {
      waypointDetail.toDeliverItemList.forEach((ToDeliverItem item) {
        item.orderList.forEach(
            (String productId, ToDeliverItemDetail toDeliverItemDetail) {
          toDeliverItemDetail.options.forEach((String option,
              ToDeliverItemDetailOption toDeliverItemDetailOption) {
            if (_totalItem.productMap[productId] == null) {
              _totalItem.productMap[productId] = TotalItemProduct(
                  productImages: toDeliverItemDetail.productImages,
                  productName: toDeliverItemDetail.productName,
                  options: {
                    option: TotalItemOption(
                      standardPrice: toDeliverItemDetailOption.standardPrice,
                      groupPrice: toDeliverItemDetailOption.groupPrice,
                      index: toDeliverItemDetailOption.index,
                      quantity: toDeliverItemDetailOption.quantity,
                      isLate: toDeliverItemDetailOption.isLate,
                      isOrdered: toDeliverItemDetailOption.isOrdered,
                    ),
                  });
            } else {
              if (_totalItem.productMap[productId].options[option] == null) {
                _totalItem.productMap[productId].options[option] =
                    TotalItemOption(
                  isOrdered: toDeliverItemDetailOption.isOrdered,
                  isLate: toDeliverItemDetailOption.isLate,
                  quantity: toDeliverItemDetailOption.quantity,
                  index: toDeliverItemDetailOption.index,
                  groupPrice: toDeliverItemDetailOption.groupPrice,
                  standardPrice: toDeliverItemDetailOption.standardPrice,
                );
              } else {
                _totalItem.productMap[productId].options[option].quantity =
                    _totalItem.productMap[productId].options[option].quantity +
                        toDeliverItemDetailOption.quantity;
              }
            }
          });
        });
      });
    });
    super.initState();
  }

  _buildViewByTotalList() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int i) {
          String productId = _totalItem.productMap.keys.toList()[i];
          TotalItemProduct totalItemProduct = _totalItem.productMap[productId];
          return ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalItemProduct.productName,
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Image.network(
                          totalItemProduct.productImages.first,
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
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int j) {
                          String option =
                              totalItemProduct.options.keys.toList()[j];
                          num quantity =
                              totalItemProduct.options[option].quantity;
                          return Container(
                              margin: EdgeInsets.only(bottom: 2),
                              child: Text(
                                '$option x$quantity',
                                style: GoogleFonts.quicksand(fontSize: 12.5),
                              ));
                        },
                        itemCount: totalItemProduct.options.length,
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        },
        itemCount: _totalItem.productMap.length,
      ),
    );
  }

  _buildViewByDeliveryList(double width, double height) {
    Map<String, List<WaypointDetail>> postcodeItemMap = {};
    _waypointDetailList.forEach((WaypointDetail waypointDetail) {
      String postcode = waypointDetail.address.addressDetails.postcode;
      if (postcodeItemMap[postcode] == null) {
        postcodeItemMap[postcode] = [];
        postcodeItemMap[postcode].add(waypointDetail);
      } else {
        postcodeItemMap[postcode].add(waypointDetail);
      }
    });
//    _toDeliverItemList.forEach((ToDeliverItem item) {
//      String postcode = item.address.addressDetails.postcode;
//      if (postcodeItemMap[postcode] == null) {
//        postcodeItemMap[postcode] = [];
//        postcodeItemMap[postcode].add(item);
//      } else {
//        postcodeItemMap[postcode].add(item);
//      }
//    });
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          String postcode = postcodeItemMap.keys.toList()[index];
          return ExpansionTile(
            children: [
              MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int i) {
                    String name = postcodeItemMap[postcode][i].receiver.name;
                    String contactNumber =
                        postcodeItemMap[postcode][i].receiver.contactNumber;
                    String address =
                        postcodeItemMap[postcode][i].address.address;
                    List<String> noteList =
                        postcodeItemMap[postcode][i].noteList;
                    List<String> deliveryIdList = postcodeItemMap[postcode][i].deliveryIdList;
                    return ExpansionTile(
                      tilePadding: EdgeInsets.only(
                          top: 0, bottom: 0, left: 16, right: 16),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1})',
                            style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: width * 0.7,
                                child: Text(
                                  name,
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                              Container(
                                width: width * 0.7,
                                child: Text(
                                  contactNumber,
                                  style: GoogleFonts.quicksand(fontSize: 12.5),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                width: width * 0.7,
                                child: Text(
                                  address,
                                  style: GoogleFonts.quicksand(fontSize: 12.5),
                                ),
                              ),
                              noteList  == null? Container():  SizedBox(
                                height: 5,
                              ),
                              noteList  == null? Container():  Container(
                                width: width * 0.7,
                                child: Text(
                                  'Note: ${noteList.join(', ')}',
                                  style: GoogleFonts.quicksand(fontSize: 12.5),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                width: width * 0.7,
                                child: Text(
                                  'No. of delivery ID: ${deliveryIdList.length}',
                                  style: GoogleFonts.quicksand(fontSize: 12.5),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ],
                      ),
                      children: [
                        ListView.builder(
                          padding: EdgeInsets.all(0),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int j) {
                            String deliveryId = postcodeItemMap[postcode][i]
                                .toDeliverItemList[j]
                                .deliveryId;
                            Map<String, Map<String, ToDeliverItemDetail>>
                                chilledOrRoomTemperatureProductMap = {
                              'frozen': {},
                              'chilled': {},
                              'room': {},
                            };
                            postcodeItemMap[postcode][i]
                                .toDeliverItemList[j]
                                .orderList
                                .forEach((String productId,
                                    ToDeliverItemDetail toDeliveryItemDetail) {
                              if (toDeliveryItemDetail.frozen) {
                                chilledOrRoomTemperatureProductMap['frozen']
                                    .addAll({productId: toDeliveryItemDetail});
                              } else if (toDeliveryItemDetail.chilled) {
                                chilledOrRoomTemperatureProductMap['chilled']
                                    .addAll({productId: toDeliveryItemDetail});
                              } else {
                                chilledOrRoomTemperatureProductMap['room']
                                    .addAll({productId: toDeliveryItemDetail});
                              }
                            });
                            return Container(
                              margin: EdgeInsets.only(left: 10,bottom: 20,right: 10),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).primaryColor,width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      'Delivery ID: $deliveryId',
                                      style: GoogleFonts.quicksand(fontSize: 12.5,    fontWeight:
                                      FontWeight.w800,),
                                    ),
                                  ),
                                  MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child:
                                        chilledOrRoomTemperatureProductMap['room']
                                                .isEmpty
                                            ? Container()
                                            : Container(
                                                margin: EdgeInsets.only(bottom:10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Room Temperature',
                                                      style:
                                                          GoogleFonts.quicksand(
                                                              fontWeight:
                                                                  FontWeight.w800,
                                                              fontSize: 17.5),
                                                    ),
                                                    ListView.builder(
                                                      padding: EdgeInsets.all(0),
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int j) {
                                                        String productId =
                                                            chilledOrRoomTemperatureProductMap[
                                                                    'room']
                                                                .keys
                                                                .toList()[j];
                                                        ToDeliverItemDetail
                                                            toDeliverItemDetail =
                                                            chilledOrRoomTemperatureProductMap[
                                                                    'room']
                                                                [productId];
                                                        return Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '${j + 1})',
                                                              style: GoogleFonts
                                                                  .quicksand(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          15),
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
                                                                    style: GoogleFonts.quicksand(
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
                                                                        borderRadius:
                                                                            BorderRadius.all(
                                                                                Radius.circular(10)),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              100,
                                                                          height:
                                                                              100,
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
                                                                              (BuildContext context,
                                                                                  int l) {
                                                                            String
                                                                                option =
                                                                                toDeliverItemDetail.options.keys.toList()[l];
                                                                            num quantity = toDeliverItemDetail
                                                                                .options[option]
                                                                                .quantity;
                                                                            return Container(
                                                                                margin: EdgeInsets.only(bottom: 2),
                                                                                child: Text(
                                                                                  '$option x$quantity',
                                                                                  style: GoogleFonts.quicksand(fontSize: 12.5),
                                                                                ));
                                                                          },
                                                                          itemCount: toDeliverItemDetail
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
                                              ),
                                  ),
                                  MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child:
                                        chilledOrRoomTemperatureProductMap[
                                                    'chilled']
                                                .isEmpty
                                            ? Container()
                                            : Container(
                                          margin: EdgeInsets.only(bottom:10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Chilled',
                                                      style:
                                                          GoogleFonts.quicksand(
                                                              fontWeight:
                                                                  FontWeight.w800,
                                                              fontSize: 17.5),
                                                    ),
                                                    ListView.builder(
                                                      padding: EdgeInsets.all(0),
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int j) {
                                                        String productId =
                                                            chilledOrRoomTemperatureProductMap[
                                                                    'chilled']
                                                                .keys
                                                                .toList()[j];
                                                        ToDeliverItemDetail
                                                            toDeliverItemDetail =
                                                            chilledOrRoomTemperatureProductMap[
                                                                    'chilled']
                                                                [productId];
                                                        return Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '${j + 1})',
                                                              style: GoogleFonts
                                                                  .quicksand(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                            SizedBox(width: 5),
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
                                                                    style: GoogleFonts.quicksand(
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
                                                                        borderRadius:
                                                                            BorderRadius.all(
                                                                                Radius.circular(10)),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              100,
                                                                          height:
                                                                              100,
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
                                                                              (BuildContext context,
                                                                                  int l) {
                                                                            String
                                                                                option =
                                                                                toDeliverItemDetail.options.keys.toList()[l];
                                                                            num quantity = toDeliverItemDetail
                                                                                .options[option]
                                                                                .quantity;
                                                                            return Container(
                                                                                margin: EdgeInsets.only(bottom: 2),
                                                                                child: Text(
                                                                                  '$option x$quantity',
                                                                                  style: GoogleFonts.quicksand(fontSize: 12.5),
                                                                                ));
                                                                          },
                                                                          itemCount: toDeliverItemDetail
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
                                              ),
                                  ),
                                  MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child:
                                        chilledOrRoomTemperatureProductMap[
                                                    'frozen']
                                                .isEmpty
                                            ? Container()
                                            : Container(
                                          margin: EdgeInsets.only(bottom:10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Frozen',
                                                      style:
                                                          GoogleFonts.quicksand(
                                                              fontWeight:
                                                                  FontWeight.w800,
                                                              fontSize: 17.5),
                                                    ),
                                                    ListView.builder(
                                                      padding: EdgeInsets.all(0),
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int j) {
                                                        String productId =
                                                            chilledOrRoomTemperatureProductMap[
                                                                    'frozen']
                                                                .keys
                                                                .toList()[j];
                                                        ToDeliverItemDetail
                                                            toDeliverItemDetail =
                                                            chilledOrRoomTemperatureProductMap[
                                                                    'frozen']
                                                                [productId];
                                                        return Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '${j + 1})',
                                                              style: GoogleFonts
                                                                  .quicksand(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                            SizedBox(width: 5),
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
                                                                    style: GoogleFonts.quicksand(
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
                                                                        borderRadius:
                                                                            BorderRadius.all(
                                                                                Radius.circular(10)),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              100,
                                                                          height:
                                                                              100,
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
                                                                              (BuildContext context,
                                                                                  int l) {
                                                                            String
                                                                                option =
                                                                                toDeliverItemDetail.options.keys.toList()[l];
                                                                            num quantity = toDeliverItemDetail
                                                                                .options[option]
                                                                                .quantity;
                                                                            return Container(
                                                                                margin: EdgeInsets.only(bottom: 2),
                                                                                child: Text(
                                                                                  '$option x$quantity',
                                                                                  style: GoogleFonts.quicksand(fontSize: 12.5),
                                                                                ));
                                                                          },
                                                                          itemCount: toDeliverItemDetail
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
                                              ),
                                  ),
                                ],
                              ),
                            );
                          },
                          itemCount: postcodeItemMap[postcode][i]
                              .toDeliverItemList
                              .length,
                        )
                      ],
                    );
                  },
                  itemCount: postcodeItemMap[postcode].length,
                ),
              ),
            ],
            title: Text(
              '$postcode (${postcodeItemMap[postcode].length} Deliveries)',
              style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold, fontSize: 20),
            ),
          );
        },
        itemCount: postcodeItemMap.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: Text(
              'Check Deliveries',
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
          body: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'View by:',
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold, fontSize: 17.5),
                    ),
                  ),
                  Expanded(
                    child: TabBar(
                      tabs: _tabs,
                      controller: _tabController,
                      labelColor: Theme.of(context).primaryColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: GoogleFonts.quicksand(fontSize: 12),
                      indicatorWeight: 3,
                      unselectedLabelColor: Colors.grey,
                      onTap: (int index) {
                        _pageController.animateToPage(index,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.fastLinearToSlowEaseIn);
                      },
                    ),
                  )
                ],
              ),
              Divider(
                height: 2,
                color: Colors.grey,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildViewByTotalList(),
                    _buildViewByDeliveryList(width, height),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
