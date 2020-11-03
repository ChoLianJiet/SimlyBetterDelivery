//Dart import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

//Third party library import
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Local import
import 'package:simply_better_delivery/state_management/main.dart';
import 'package:simply_better_delivery/model/to_deliver_item.dart';
import 'package:simply_better_delivery/utils/navigation_animation.dart';
import 'package:simply_better_delivery/pages/delivered_detail_page.dart';

class DeliveriedPage extends StatefulWidget {
  MainStateManager manager;

  DeliveriedPage({@required this.manager});

  @override
  State<StatefulWidget> createState() {
    return _DeliveriedPageState();
  }
}

class _DeliveriedPageState extends State<DeliveriedPage> {
  CalendarController _calendarController;
  bool _fetchLoading = false;
  List<WaypointDetail> _waypointDetailList;
  List<WaypointDetail> _completedWaypointDetailList;
  List<WaypointDetail> _undeliveredWaypointDetailList;
  num _totalEarned;
  num _totalClaimed;

  @override
  void initState() {
    _calendarController = CalendarController();
    _fetchDeliveries();
    super.initState();
  }

  Future _fetchDeliveries() async {
    setState(() {
      _waypointDetailList = null;
    });
    QuerySnapshot querySnapshot;
    if (_calendarController.selectedDay == null) {
      querySnapshot = await Firestore.instance
          .collection('drivers')
          .document(widget.manager.driver.driverId)
          .collection('trips')
          .where('delivered_out_date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.parse(
                  DateFormat('yyyy-MM-dd 00:00:00').format(DateTime.now()))))
          .where('delivered_out_date',
              isLessThanOrEqualTo: Timestamp.fromDate(DateTime.parse(
                  DateFormat('yyyy-MM-dd 23:59:59').format(DateTime.now()))))
          .getDocuments();
    } else {
      querySnapshot = await Firestore.instance
          .collection('drivers')
          .document(widget.manager.driver.driverId)
          .collection('trips')
          .where('delivered_out_date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.parse(
                  DateFormat('yyyy-MM-dd 00:00:00')
                      .format(_calendarController.selectedDay))))
          .where('delivered_out_date',
              isLessThanOrEqualTo: Timestamp.fromDate(DateTime.parse(
                  DateFormat('yyyy-MM-dd 23:59:59')
                      .format(_calendarController.selectedDay))))
          .getDocuments();
    }

    _waypointDetailList = [];
    _completedWaypointDetailList = [];
    _undeliveredWaypointDetailList = [];
    _totalEarned = 0;
    _totalClaimed = 0;

    querySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
      _totalEarned = _totalEarned + documentSnapshot['total_earned'];
      _totalClaimed = _totalClaimed + documentSnapshot['total_claimed'];
      documentSnapshot.data['waypoints'].forEach((dynamic waypointDetails) {
        _waypointDetailList.add(WaypointDetail.fromFirestore(
            documentSnapshot.documentID, waypointDetails));
        if (waypointDetails['delivered_successfully'] != null) {
          if (waypointDetails['delivered_successfully']) {
            _completedWaypointDetailList.add(WaypointDetail.fromFirestore(
                documentSnapshot.documentID, waypointDetails));
          } else {
            _undeliveredWaypointDetailList.add(WaypointDetail.fromFirestore(
                documentSnapshot.documentID, waypointDetails));
          }
        }
      });
    });

    if (mounted) {
      setState(() {
        if (_waypointDetailList.isEmpty) {
          _calendarController.setCalendarFormat(CalendarFormat.month);
        } else {
          _calendarController.setCalendarFormat(CalendarFormat.week);
        }
      });
    }
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
                'Delivered',
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
                TableCalendar(
                  availableGestures: AvailableGestures.horizontalSwipe,
                  headerVisible: true,
                  headerStyle: HeaderStyle(
                    formatButtonTextStyle: GoogleFonts.quicksand(),
                    titleTextStyle: GoogleFonts.quicksand(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.5),
                    formatButtonVisible: false,
                  ),
                  calendarStyle: CalendarStyle(
                    todayStyle: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    unavailableStyle: GoogleFonts.quicksand(),
                    weekdayStyle: GoogleFonts.quicksand(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    weekendStyle: GoogleFonts.quicksand(
                        color: Colors.red, fontWeight: FontWeight.bold),
                    outsideHolidayStyle: GoogleFonts.quicksand(),
                    outsideStyle: GoogleFonts.quicksand(color: Colors.grey),
                    outsideWeekendStyle:
                        GoogleFonts.quicksand(color: Colors.red[200]),
                    selectedStyle: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    holidayStyle: GoogleFonts.quicksand(),
                  ),
                  initialSelectedDay: DateTime.now(),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.quicksand(color: Colors.black),
                    weekendStyle: GoogleFonts.quicksand(color: Colors.red),
                  ),
                  onHeaderTapped: (DateTime now) {
                    return DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        theme: DatePickerTheme(
                          doneStyle: GoogleFonts.quicksand(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          cancelStyle: GoogleFonts.quicksand(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                          itemStyle: GoogleFonts.quicksand(),
                        ),
                        onChanged: (date) {}, onConfirm: (date) {
                      setState(() {
                        _calendarController.setSelectedDay(date);
                        _fetchDeliveries();
                      });
                    }, locale: LocaleType.en);
                  },
                  onDaySelected: (DateTime date, List<dynamic> events) {
                    setState(() {
                      _calendarController.setSelectedDay(date);
                      _fetchDeliveries();
                    });
                  },
                  calendarController: _calendarController,
                ),
                Expanded(
                  child: _waypointDetailList == null
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : _waypointDetailList.isEmpty
                          ? Center(
                              child: Text(
                                'No deliveries for ${DateFormat('dd MMM yyyy').format(_calendarController.selectedDay)}',
                                style: GoogleFonts.quicksand(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 10, right: 10, bottom: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                            DateFormat('dd MMM yyyy').format(
                                                _calendarController.selectedDay),
                                            style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17.5)),
                                        Text(
                                            'Total Earned: RM${_totalEarned.toStringAsFixed(2)}',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 17.5,
                                            )),
                                        Text(
                                            'Total Claimed: RM${_totalClaimed.toStringAsFixed(2)}',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 17.5,
                                            )),
                                        Text(
                                            'Completed Deliveries: ${_completedWaypointDetailList.length}',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 17.5,
                                            )),
                                        Text(
                                            'Undelivered Deliveries: ${_undeliveredWaypointDetailList.length}',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 17.5,
                                            )),
                                      ],
                                    ),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                     WaypointDetail waypointDetail =
                                          _waypointDetailList[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              EnterExitRoute(
                                                  exitPage: widget,
                                                  enterPage:
                                                      DeliveredDetailPage(
                                                    manager: widget.manager,
                                                    waypointDetail:
                                                        waypointDetail,
                                                  )));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: 10, right: 10, bottom: 10),
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: waypointDetail
                                                            .completedDate ==
                                                        null
                                                    ? Colors.orange
                                                    : waypointDetail
                                                                .deliveredSuccessfully ==
                                                            null
                                                        ? Colors.orange
                                                        : waypointDetail
                                                                .deliveredSuccessfully
                                                            ? Colors.green
                                                            : Colors.red,
                                                width: 2),
                                          ),
                                          child: Stack(
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: width,
                                                    child: Text(
                                                      waypointDetail
                                                          .receiver.name,
                                                      style:
                                                          GoogleFonts.quicksand(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: width * 0.6,
                                                    child: Text(
                                                      waypointDetail.receiver
                                                          .contactNumber,
                                                      style:
                                                          GoogleFonts.quicksand(
                                                              fontSize: 12.5),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  waypointDetail.completedDate ==
                                                          null
                                                      ? Text(
                                                          'On the way to customer...',
                                                          style: GoogleFonts
                                                              .quicksand(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        )
                                                      : Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            waypointDetail
                                                                        .earned ==
                                                                    null
                                                                ? !waypointDetail
                                                                        .deliveredSuccessfully
                                                                    ? waypointDetail.failedReason ==
                                                                            ''
                                                                        ? Text(
                                                                            'Failed Reason: N/A',
                                                                            style:
                                                                                GoogleFonts.quicksand(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: Colors.black54,
                                                                            ),
                                                                          )
                                                                        : Container(
                                                                            width:
                                                                                width * 0.8,
                                                                            child:
                                                                                Text(
                                                                              'Failed Reason: ${waypointDetail.failedReason}',
                                                                              style: GoogleFonts.quicksand(
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: Colors.black54,
                                                                              ),
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                    : Text(
                                                                        'Earned: Calculating',
                                                                        style: GoogleFonts
                                                                            .quicksand(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              Colors.black54,
                                                                        ),
                                                                      )
                                                                : Text(
                                                                    'Earned: ${waypointDetail.earned.toStringAsFixed(2)}',
                                                                    style: GoogleFonts
                                                                        .quicksand(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .black54,
                                                                    ),
                                                                  ),
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                            waypointDetail
                                                                        .earned ==
                                                                    null
                                                                ? Container()
                                                                : Text(
                                                              waypointDetail
                                                                            .claimed
                                                                        ? 'Claimed: Yes'
                                                                        : 'Claimed: Not Yet',
                                                                    style: GoogleFonts
                                                                        .quicksand(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .black54,
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                ],
                                              ),
                                              Positioned(
                                                right: 5,
                                                top: 5,
                                                child: waypointDetail
                                                            .completedDate ==
                                                        null
                                                    ? Text(
                                                        'On Going',
                                                        style: GoogleFonts
                                                            .quicksand(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .orange),
                                                      )
                                                    : waypointDetail
                                                                .deliveredSuccessfully ==
                                                            null
                                                        ? Text(
                                                            'On Going',
                                                            style: GoogleFonts
                                                                .quicksand(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .orange),
                                                          )
                                                        : waypointDetail
                                                                .deliveredSuccessfully
                                                            ? Text(
                                                                'Completed',
                                                                style: GoogleFonts.quicksand(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .green),
                                                              )
                                                            : Text(
                                                                'Undelivered',
                                                                style: GoogleFonts.quicksand(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: _waypointDetailList.length,
                                  ),
                                ],
                              ),
                          ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }
}
