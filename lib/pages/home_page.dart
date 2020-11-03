//Dart import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//Third party library import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

//Local import
import 'package:simply_better_delivery/state_management/main.dart';
import 'package:simply_better_delivery/model/to_deliver_item.dart';
import 'package:simply_better_delivery/pages/widgets/start_delivery_dialog.dart';
import 'package:simply_better_delivery/utils/navigation_animation.dart';
import 'package:simply_better_delivery/pages/check_deliveries_page.dart';
import 'package:simply_better_delivery/pages/widgets/home_page_date_time_now.dart';
import 'package:simply_better_delivery/pages/delivery_detail_page.dart';

class HomePage extends StatefulWidget {
  MainStateManager manager;

  HomePage({@required this.manager});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;
    return Container(
      color: Theme
          .of(context)
          .primaryColor,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_scaffoldKey.currentState.isDrawerOpen) {
              _scaffoldKey.currentState.openEndDrawer();
            }
            if (ModalRoute
                .of(context)
                .settings
                .name != '/') {
              Navigator.pop(context);
            }
            return;
          },
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xffD485C1), Color(0xff3C418A)])),
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                title: Text(
                  'Simply Better Delivery',
                  style: GoogleFonts.quicksand(
                    color: Color(0xff9A3D76),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                iconTheme: IconThemeData(color: Color(0xff9A3D76)),
              ),
              drawer: Drawer(
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0.0,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          _scaffoldKey.currentState.openEndDrawer();
                        },
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      trailing: Icon(Icons.person),
                      title: Text(
                        'Profile',
                        style:
                        GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, '/delivered');
                      },
                      trailing: Icon(Icons.drive_eta),
                      title: Text('Delivered',
                          style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    ListTile(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Log Out'),
                                content: Text(
                                    'Are you sure you want to Log Out from Simply Better Delivery?'),
                                actions: [
                                  FlatButton(
                                    child: Text('Yes'),
                                    onPressed: () {
                                      widget.manager.logout();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('No'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              );
                            });
                      },
                      trailing: Icon(Icons.exit_to_app),
                      title: Text('Log Out'),
                    ),
                  ],
                ),
              ),
              body: Container(
                width: width,
                height: height,
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('drivers')
                      .document(widget.manager.driver.driverId)
                      .collection('trips')
                      .where('completed', isEqualTo: false)
                      .orderBy('time_created')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> querySnapshot) {
                    if (querySnapshot.data == null) {
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Color(0xffCCC9DF),
                        ),
                      );
                    } else if (querySnapshot.data.documents.isEmpty) {
                      return Center(
                        child: Text(
                          'No Deliveries for now',
                          style: GoogleFonts.quicksand(
                              fontSize: 30, color: Color(0xffCCC9DF)),
                        ),
                      );
                    } else if (querySnapshot.data.documents
                        .any((DocumentSnapshot documentSnapshot) {
                      return documentSnapshot.data['delivered_out_date'] ==
                          null;
                    })) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('dd MMM yyyy').format(DateTime.now()),
                              style: GoogleFonts.quicksand(
                                  fontSize: 30, color: Color(0xffCCC9DF)),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FlatButton(
                              child: Text(
                                'Check Deliveries',
                                style: GoogleFonts.quicksand(
                                    fontSize: 20, color: Color(0xffCCC9DF)),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    EnterExitRoute(
                                        exitPage: widget,
                                        enterPage: CheckDeliveriesPage(
                                            manager: widget.manager,
                                            querySnapshot:
                                            querySnapshot.data)));
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            FlatButton(
                              child: Text(
                                'Start',
                                style: GoogleFonts.quicksand(
                                    fontSize: 20, color: Color(0xffCCC9DF)),
                              ),
                              onPressed: () {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    child: StartDeliveryDialog(
                                      manager: widget.manager,
                                      querySnapshot: querySnapshot.data,
                                    ));
                              },
                            )
                          ],
                        ),
                      );
                    } else {
                      List<WaypointDetail> waypointDetailList = [];
                      querySnapshot.data.documents
                          .forEach((DocumentSnapshot documentSnapshot) {
                        if (!documentSnapshot.data['completed']) {
                          documentSnapshot.data['waypoints']
                              .forEach((dynamic waypointDetails) {
                            if (waypointDetails['completed_date'] == null) {
                              for (int i = 0;
                              i < querySnapshot.data.documents.length;
                              i++) {
                                DocumentSnapshot documentSnapshot =
                                querySnapshot.data.documents[i];
                                waypointDetailList.add(
                                    WaypointDetail.fromFirestore(
                                        documentSnapshot.documentID,
                                        waypointDetails));
                              }
                            }
                          });
                        }
                      });
                      print('home ${waypointDetailList.length}');
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HomePageDateTimeNowText(
                                  manager: widget.manager,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.store,
                                      color: Color(0xffCCC9DF),
                                      size: 100,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Starting Point',
                                          style: GoogleFonts.quicksand(
                                              fontSize: 20,
                                              color: Color(0xffCCC9DF),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          width: width * 0.6,
                                          child: Text(
                                            querySnapshot.data.documents.last
                                                .data['starting_waypoint']
                                            ['address'],
                                            style: GoogleFonts.quicksand(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xffCCC9DF),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          width: width * 0.6,
                                          child: Text(
                                            'Departed at ${DateFormat(
                                                'HH:mm:ss').format(
                                                querySnapshot.data.documents
                                                    .last
                                                    .data['delivered_out_date']
                                                    .toDate())}',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 12.5,
                                              color: Color(0xffCCC9DF),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  WaypointDetail waypointDetail =
                                  waypointDetailList[index];
                                  DateTime dateTime = querySnapshot.data
                                      .documents.last.data['delivered_out_date']
                                      .toDate();
                                  Duration duration = Duration(milliseconds: 0);
                                  for (int i = 0; i <= index; i++) {
                                    duration =
                                        duration + waypointDetail.duration;
                                  }
                                  return TimelineTile(
                                    alignment: TimelineAlign.manual,
                                    lineX: 0.2,
                                    isFirst: index == 0 ? true : false,
                                    topLineStyle: LineStyle(
                                        color: Color(0xffCCC9DF), width: 2.5),
                                    indicatorStyle: IndicatorStyle(
                                        color: Color(0xffCCC9DF),
                                        width: 15,
                                        indicatorY: 0.25),
                                    isLast: index ==
                                        waypointDetail
                                            .toDeliverItemList.length -
                                            1
                                        ? true
                                        : false,
                                    rightChild: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return DeliveryDetailPage(
                                                  manager: widget.manager,
                                                  waypointDetail: waypointDetail,
                                                  index: index,
                                                );
                                              }),
                                        );
                                      },
                                      child: Hero(
                                        flightShuttleBuilder: (
                                            BuildContext flightContext,
                                            Animation<double> animation,
                                            HeroFlightDirection flightDirection,
                                            BuildContext fromHeroContext,
                                            BuildContext toHeroContext,) {
                                          return SingleChildScrollView(
                                            child: fromHeroContext.widget,
                                          );
                                        },
                                        tag: 'delivery_detail_$index',
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: Container(
                                            margin: EdgeInsets.all(10),
                                            padding: EdgeInsets.only(left: 10,right: 50,bottom: 10,top: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: width * 0.6,
                                                  child: Text(
                                                    waypointDetail
                                                        .receiver.name,
                                                    style:
                                                    GoogleFonts.quicksand(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                                Container(
                                                  width: width * 0.6,
                                                  child: Text(
                                                    waypointDetail
                                                        .receiver.contactNumber,
                                                    style:
                                                    GoogleFonts.quicksand(
                                                        fontSize: 12.5),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  width: width * 0.6,
                                                  child: Text(
                                                    waypointDetail
                                                        .address.address,
                                                    style:
                                                    GoogleFonts.quicksand(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                      FontWeight.w500,
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
                                                    'No. of delivery ID: ${ waypointDetail.deliveryIdList.length}', style:
                                                  GoogleFonts.quicksand(
                                                      fontSize: 10),),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    leftChild: Container(
                                      alignment: Alignment(0, -0.6),
                                      child: Text(
                                        DateFormat('HH:mm')
                                            .format(dateTime.add(duration)),
                                        style: GoogleFonts.quicksand(
                                          color: Color(0xffCCC9DF),
                                          fontSize: 17.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
//                                return ListView.builder(
//                                  padding: EdgeInsets.all(10),
//                                  physics: AlwaysScrollableScrollPhysics(),
//                                  shrinkWrap: true,
//                                  itemBuilder: (BuildContext context, int i) {
//                                    ToDeliverItem toDeliverItem =
//                                        waypointDetail.toDeliverItemList[i];
//                                    String deliveryId = toDeliverItem.deliveryId;
//                                    DateTime dateTime = querySnapshot.data
//                                        .documents.last.data['delivered_out_date']
//                                        .toDate();
//                                    Duration duration = Duration(milliseconds: 0);
//                                    for (int z = 0; z <= i; z++) {
//                                      duration = duration +
//                                          waypointDetail.duration;
//                                    }
//                                    return TimelineTile(
//                                      alignment: TimelineAlign.manual,
//                                      lineX: 0.2,
//                                      isFirst: i == 0 ? true : false,
//                                      topLineStyle: LineStyle(
//                                          color: Color(0xffCCC9DF), width: 2.5),
//                                      indicatorStyle: IndicatorStyle(
//                                          color: Color(0xffCCC9DF),
//                                          width: 15,
//                                          indicatorY: 0.25),
//                                      isLast:
//                                      i ==  waypointDetail.toDeliverItemList.length - 1
//                                          ? true
//                                          : false,
//                                      rightChild: GestureDetector(
//                                        onTap: () {
//                                          Navigator.push(
//                                            context,
//                                            MaterialPageRoute(
//                                                builder: (BuildContext context) {
//                                                  return DeliveryDetailPage(
//                                                    manager: widget.manager,
//                                                    waypointDetail: waypointDetail,
//                                                    index: i,
//                                                  );
//                                                }),
//                                          );
//                                        },
//                                        child: Hero(
//                                          flightShuttleBuilder: (
//                                              BuildContext flightContext,
//                                              Animation<double> animation,
//                                              HeroFlightDirection flightDirection,
//                                              BuildContext fromHeroContext,
//                                              BuildContext toHeroContext,
//                                              ) {
//                                            return SingleChildScrollView(
//                                              child: fromHeroContext.widget,
//                                            );
//                                          },
//                                          tag: 'delivery_detail_$i',
//                                          child: Material(
//                                            type: MaterialType.transparency,
//                                            child: Container(
//                                              margin: EdgeInsets.all(10),
//                                              padding: EdgeInsets.all(10),
//                                              decoration: BoxDecoration(
//                                                color: Colors.white,
//                                                borderRadius: BorderRadius.all(
//                                                    Radius.circular(10)),
//                                              ),
//                                              child: Column(
//                                                mainAxisAlignment:
//                                                MainAxisAlignment.start,
//                                                crossAxisAlignment:
//                                                CrossAxisAlignment.start,
//                                                mainAxisSize: MainAxisSize.min,
//                                                children: [
//                                                  Container(
//                                                    width: width * 0.6,
//                                                    child: Text(
//                                                      waypointDetail.receiver.name,
//                                                      style:
//                                                      GoogleFonts.quicksand(
//                                                          fontWeight:
//                                                          FontWeight.bold,
//                                                          fontSize: 15),
//                                                    ),
//                                                  ),
//                                                  Container(
//                                                    width: width * 0.6,
//                                                    child: Text(
//                                                      waypointDetail
//                                                          .receiver.contactNumber,
//                                                      style:
//                                                      GoogleFonts.quicksand(
//                                                          fontSize: 12.5),
//                                                    ),
//                                                  ),
//                                                  SizedBox(
//                                                    height: 5,
//                                                  ),
//                                                  Container(
//                                                    height: 75,
//                                                    width: width * 0.6,
//                                                    child: Text(
//                                                     waypointDetail
//                                                          .address.address,
//                                                      style:
//                                                      GoogleFonts.quicksand(
//                                                        fontSize: 12.5,
//                                                        fontWeight:
//                                                        FontWeight.w500,
//                                                        color: Colors.black54,
//                                                      ),
//                                                    ),
//                                                  ),
//                                                  SizedBox(
//                                                    height: 5,
//                                                  ),
//                                                  Container(
//                                                    width: width * 0.7,
//                                                    child: Text(
//                                                      'Delivery ID: ${toDeliverItem.deliveryId}',
//                                                      style:
//                                                      GoogleFonts.quicksand(
//                                                          fontSize: 10),
//                                                    ),
//                                                  ),
//                                                ],
//                                              ),
//                                            ),
//                                          ),
//                                        ),
//                                      ),
//                                      leftChild: Container(
//                                        alignment: Alignment(0, -0.6),
//                                        child: Text(
//                                          DateFormat('HH:mm')
//                                              .format(dateTime.add(duration)),
//                                          style: GoogleFonts.quicksand(
//                                            color: Color(0xffCCC9DF),
//                                            fontSize: 17.5,
//                                            fontWeight: FontWeight.bold,
//                                          ),
//                                        ),
//                                      ),
//                                    );
//                                  },
//                                  itemCount: waypointDetail.toDeliverItemList.length,
//                                );
                                },
                                itemCount: waypointDetailList.length,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
