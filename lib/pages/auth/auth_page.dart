//Dart import
import 'package:flutter/material.dart';

//Third party library import
import 'package:provider/provider.dart';

//Local import
import 'package:simply_better_delivery/state_management/main.dart';

class AuthPage extends StatefulWidget {
  MainStateManager manager;

  AuthPage({Key key, this.manager}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController _phoneTextEditingController = TextEditingController();
  TextEditingController _codeTextEditingController = TextEditingController();
  GlobalKey<FormState> _phoneNumFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> _codeFormKey = GlobalKey<FormState>();
  FocusNode _phoneFocusNode = FocusNode();
  FocusNode _codeFocusNode = FocusNode();
  bool _loginLoading = false;

  _login(context, MainStateManager manager) async {
    print(manager.firebaseUser == null);
    setState(() {
      _loginLoading = true;
    });

    if (manager.firebaseUser == null) {
      await manager
          .verifyPhoneNumber(context, _phoneTextEditingController)
          .then((value) {
        setState(() {
            manager.needCode = true;
          _loginLoading = false;
        });
      });
    } else {
      _loginLoading = false;
      manager.userAuthSubject.add(true);
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
              return;
            },
            child: Container(
              color: Theme.of(context).primaryColor,
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.white,
                  body: Stack(
                    children: <Widget>[
                      SingleChildScrollView(child: Consumer<MainStateManager>(
                        builder: (builder, manager, child) {
                          print(
                              ' ${manager.needCode} , ${manager.verificationSuccessful}');
                          if (manager.needCode) {
                            _loginLoading = false;
                          }

                          return Center(
                            child: Container(
                              margin:
                                  EdgeInsets.symmetric(vertical: height * 0.1),
                              height: height * 0.8,
                              width: width * 0.8,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  ///Logo
                                  Container(
                                    height: height * 0.2,
                                    padding: EdgeInsets.all(25),
                                    child: Image(
                                      image: AssetImage(
                                          'assets/simply_better_delivery_icon.png'),
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.white70,
                                    ),
                                  ),

                                  Container(
                                    height: height * 0.25,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        /// Login form
                                        Form(
                                          key: _phoneNumFormKey,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 5),
                                            child: TextFormField(
                                              onEditingComplete: () {
                                                if (!_phoneNumFormKey
                                                    .currentState
                                                    .validate()) {
                                                  return;
                                                }

                                                FocusScope.of(context)
                                                    .unfocus();
                                                if (manager.needCode) {
                                                  setState(() {
                                                    manager
                                                        .signInWithPhoneNumber(
                                                            context,
                                                            _codeTextEditingController
                                                                .text)
                                                        .then((value) {});
                                                  });
                                                } else {
                                                  _login(
                                                      context, widget.manager);
                                                }
                                              },
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: false,
                                                      decimal: false),
                                              focusNode: _phoneFocusNode,
                                              controller:
                                                  _phoneTextEditingController,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .accentColor),
                                              decoration: new InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Phone',
                                                hintStyle: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                                icon: Wrap(
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.phone,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      '+60',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              validator: (String value) {
                                                if (value.isEmpty) {
                                                  return 'Please enter your Phone number';
                                                } else if (value.length < 9 ||
                                                    value.length > 12 ||
                                                    !RegExp("^\\d+\$")
                                                        .hasMatch(value)) {
                                                  return 'Please enter a valid Phone number';
                                                } else {
                                                  return null;
                                                }
                                              },
                                              textInputAction:
                                                  TextInputAction.next,
                                              onFieldSubmitted: (String term) {
                                                if (!_phoneNumFormKey
                                                    .currentState
                                                    .validate()) {
                                                  return;
                                                }
                                                _phoneFocusNode.unfocus();
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        _codeFocusNode);
                                              },
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                          ),
                                        ),

                                        /// SMS Code
                                        manager.needCode
                                            ? Form(
                                                key: _codeFormKey,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                        width: width * 0.4,
                                                        child: TextFormField(
                                                          onEditingComplete:
                                                              () {
                                                            if (!_phoneNumFormKey
                                                                .currentState
                                                                .validate()) {
                                                              return;
                                                            }

                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            if (manager
                                                                .needCode) {
                                                              setState(() {
                                                                manager
                                                                    .signInWithPhoneNumber(
                                                                        context,
                                                                        _codeTextEditingController
                                                                            .text)
                                                                    .then(
                                                                        (value) {});
                                                              });
                                                            } else {
                                                              _login(
                                                                  context,
                                                                  widget
                                                                      .manager);
                                                            }
                                                          },
                                                          keyboardType: TextInputType
                                                              .numberWithOptions(
                                                                  signed: false,
                                                                  decimal:
                                                                      false),
                                                          focusNode:
                                                              _codeFocusNode,
                                                          controller:
                                                              _codeTextEditingController,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor),
                                                          decoration:
                                                              new InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText:
                                                                'Verification Code',
                                                            hintStyle: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor),
                                                            icon: Icon(
                                                              Icons.lock,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                            ),
                                                          ),
                                                          validator:
                                                              (String value) {
                                                            if (value.isEmpty) {
                                                              return 'Please enter a Verification Code';
                                                            } else {
                                                              return null;
                                                            }
                                                          },
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          onFieldSubmitted:
                                                              (String term) {
                                                            if (!_phoneNumFormKey
                                                                .currentState
                                                                .validate()) {
                                                              return;
                                                            }
                                                            if (!_codeFormKey
                                                                .currentState
                                                                .validate()) {
                                                              return;
                                                            }
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                          },
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      FlatButton(
                                                        onPressed: () {
                                                          widget.manager
                                                              .verifyPhoneNumber(
                                                                  context,
                                                                  _phoneTextEditingController);
                                                        },
                                                        child: Text('Resend'),
                                                      ),
                                                    ],
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                  _loginLoading || manager.verifyLoading
                                      ? Center(
                                          child: Container(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                              )),
                                        )
                                      : FlatButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100.0)),
                                          color: Theme.of(context).primaryColor,
                                          child: Container(
                                              padding: EdgeInsets.all(15),
                                              child: Text(
                                                'Login',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .backgroundColor),
                                              )),
                                          onPressed: () {
                                            _phoneNumFormKey.currentState
                                                .validate();
                                            if (!_phoneNumFormKey.currentState
                                                .validate()) {
                                              return;
                                            } else {
                                              FocusScope.of(context).unfocus();
                                              if (manager.needCode) {
                                                _codeFormKey.currentState
                                                    .validate();
                                                if (!_codeFormKey.currentState
                                                    .validate()) {
                                                  setState(() {
                                                    _loginLoading = false;
                                                  });
                                                  return;
                                                }
                                                setState(() {
                                                  manager
                                                      .signInWithPhoneNumber(
                                                          context,
                                                          _codeTextEditingController
                                                              .text)
                                                      .then((value) {
                                                        setState(() {
                                                          _loginLoading = false;
                                                        });
                                                  });
                                                });
                                              } else {
                                                _login(context, widget.manager);
                                              }
                                            }
                                          },
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                      ))
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
