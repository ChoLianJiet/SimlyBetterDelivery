//Dart import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';

//Third party library import

//Local import
import 'package:simply_better_delivery/state_management/main.dart';

class ProfilePage extends StatefulWidget {
  MainStateManager manager;

  ProfilePage({@required this.manager});

  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
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
          child: FutureBuilder(
              future: Firestore.instance
                  .collection('drivers')
                  .document(widget.manager.driver.driverId)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> documentSnapshot) {
                if (documentSnapshot.data == null) {
                  return Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0.0,
                      title: Text(
                        'Profile',
                        style: GoogleFonts.quicksand(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  num deliveriesMade =
                      documentSnapshot.data['total_deliveries_delivered'];
                  num totalEarned = documentSnapshot.data['total_earned'];
                  return Stack(
                    children: [
                      Container(
                        color: Theme.of(context).backgroundColor,
                      ),
                      ClipPath(
                        clipper: TopContainerClipper(),
                        child: Container(
                          height: 350,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                Color(0xffD485C1),
                                Color(0xff3C418A)
                              ])),
                        ),
                      ),
                      Scaffold(
                        backgroundColor: Colors.transparent,
                        appBar: AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0.0,
                          title: Text(
                            'Profile',
                            style: GoogleFonts.quicksand(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          leading: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        body: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.all(20),
                              height: 275,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Color(0xffCCC9DF),
                                        shape: BoxShape.circle),
                                    child: Icon(
                                      Icons.person,
                                      color: Theme.of(context).primaryColor,
                                      size: 50,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: width * 0.9,
                                    alignment: Alignment.center,
                                    child: Text(
                                      widget.manager.driver.name,
                                      style: GoogleFonts.quicksand(
                                          color: Color(0xffCCC9DF),
                                          fontSize: 35,
                                          letterSpacing: 3),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Deliveries Made',
                                              style: GoogleFonts.quicksand(
                                                color: Color(0xffCCC9DF),
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              deliveriesMade.toString(),
                                              style: GoogleFonts.quicksand(
                                                color: Color(0xffCCC9DF),
                                                fontSize: 30,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Earned (MYR)',
                                              style: GoogleFonts.quicksand(
                                                color: Color(0xffCCC9DF),
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              totalEarned.toStringAsFixed(2),
                                              style: GoogleFonts.quicksand(
                                                color: Color(0xffCCC9DF),
                                                fontSize: 30,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Gender',
                                              style: GoogleFonts.quicksand(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              widget.manager.driver.gender,
                                              style: GoogleFonts.quicksand(
                                                color: Colors.black,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'H/P',
                                              style: GoogleFonts.quicksand(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              widget
                                                  .manager.driver.contactNumber,
                                              style: GoogleFonts.quicksand(
                                                color: Colors.black,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'D.O.B',
                                              style: GoogleFonts.quicksand(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('dd MMM yyyy').format(
                                                  widget.manager.driver
                                                      .dateOfBirth),
                                              style: GoogleFonts.quicksand(
                                                color: Colors.black,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Column(    mainAxisAlignment:
                                      MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'A',
                                            style: GoogleFonts.quicksand(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            widget
                                                .manager.driver.address.address,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.quicksand(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }
}

class TopContainerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final height = size.height;
    final width = size.width;
    final double arcRadius = 100.0;

    final Path path = Path();

    ///Left side
    path.moveTo(0.0, 0.0);
    path.lineTo(0.0, (height / 3));

    ///Bottom left corner
    path.quadraticBezierTo(
        (width / 2) - (width / 1.15), height, width / 2, height);

    ///Bottom right corner
    path.quadraticBezierTo(
        (width / 2) + (width / 1.15), height, width, (height / 3));

    ///Right side
    path.lineTo(width, (height / 2));
    path.lineTo(width, 0.0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
