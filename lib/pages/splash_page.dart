//Dart import
import 'package:flutter/material.dart';
import 'dart:async';

//Third party library import

//Local import
import 'package:simply_better_delivery/state_management/main.dart';

class SplashPage extends StatefulWidget {
  MainStateManager manager;

  SplashPage({@required this.manager});

  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin{

  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(seconds: 3), vsync: this);
    _animation = Tween(begin: 1.5, end: 0.35).animate(CurvedAnimation(
        curve: Interval(0.0, 0.6, curve: Curves.decelerate),
        parent: _animationController));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    _animationController.forward();
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            return;
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            body: Stack(
              children: <Widget>[
                AnimatedBuilder(
                  animation: _animationController,
                  child: Container(
                    height: height,
                    width: 100,
                    child: Image(
                      image: AssetImage('assets/simply_better_delivery_icon.png'),
                    ),
                  ),
                  builder: (BuildContext context, Widget child) {
                    return Transform(
                      transform: Matrix4.translationValues(
                          _animation.value * width, 0.0, 0.0),
                      child: child,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
