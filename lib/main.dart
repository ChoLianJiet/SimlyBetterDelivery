//Dart import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Third party library import
import 'package:provider/provider.dart';

//Local import
import 'package:simply_better_delivery/state_management/main.dart';
import 'package:simply_better_delivery/pages/splash_page.dart';
import 'package:simply_better_delivery/pages/home_page.dart';
import 'package:simply_better_delivery/pages/auth/auth_page.dart';
import 'package:simply_better_delivery/pages/auth/profile_setup_page.dart';
import 'package:simply_better_delivery/pages/profile_page.dart';
import 'package:simply_better_delivery/pages/delivered_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  MainStateManager _manager = MainStateManager();
  bool _isAuthenticated = false;
  bool _userHasProfileSubject = false;
  bool _splashFinish = false;

  @override
  void initState() {
    _manager.userAuthSubject.listen((bool isAuthenticated) async {
      if (isAuthenticated) {
        _manager.setVerifyLoading(false);
        await _manager.getDriverProfile();
      }
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
      Future.delayed(Duration(seconds: 3), () {
        if(!_splashFinish){
         setState(() {
           _splashFinish = true;
         });
        }
      });
    });
    _manager.userHasProfileSubject.listen((bool hasProfile)  {

      setState(() {
        _userHasProfileSubject = hasProfile;
      });
    });
    _navigateToMainPage();
    super.initState();
  }

  Future _navigateToMainPage() async {
    await _manager.autoAuthenticate();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MainStateManager>.value(
          value: _manager,
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
          ///Headline 1 page title (except home page and profile page)
          textTheme: TextTheme(

            ///Headline 1 page title (except home page and profile page)
            headline1: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 25,
            ),
            ///Headline 3 for page subtitle's small section (except home page and profile page)
            headline3: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          primaryColor: Color(0xff8773FF),
          accentColor: Colors.indigo,
          cursorColor: Color(0xff7D518F),
          splashColor: Color(0xff00ffff),
          backgroundColor: Color(0xfff3f3f3),
          buttonColor: Color(0xff675BD2),
          cardColor: Colors.white,
        ),
        routes: {
          '/': (BuildContext build) =>!_splashFinish? SplashPage(manager: _manager,) :!_isAuthenticated
              ? AuthPage(
                  manager: _manager,
                )
              : !_userHasProfileSubject
                  ? ProfileSetupPage(
                      manager: _manager,
                    )
                  : HomePage(
                      manager: _manager,
                    ),
          '/profile':(BuildContext build) =>!_splashFinish? SplashPage(manager: _manager,) :!_isAuthenticated
              ? AuthPage(
            manager: _manager,
          )
              : !_userHasProfileSubject
              ? ProfileSetupPage(
            manager: _manager,
          )
              : ProfilePage(
            manager: _manager,
          ),
          '/delivered':(BuildContext build) =>!_splashFinish? SplashPage(manager: _manager,) :!_isAuthenticated
              ? AuthPage(
            manager: _manager,
          )
              : !_userHasProfileSubject
              ? ProfileSetupPage(
            manager: _manager,
          )
              : DeliveriedPage(
            manager: _manager,
          ),
        },
      ),
    );
  }
}

class EnterExitRoute extends PageRouteBuilder {
  final Widget enterPage;
  final Widget exitPage;
  EnterExitRoute({this.exitPage, this.enterPage})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    enterPage,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        Stack(
          children: <Widget>[
            SlideTransition(
              position: new Tween<Offset>(
                begin: const Offset(0.0, 0.0),
                end: const Offset(-1.0, 0.0),
              ).animate(animation),
              child: exitPage,
            ),
            SlideTransition(
              position: new Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: enterPage,
            )
          ],
        ),
  );
}
