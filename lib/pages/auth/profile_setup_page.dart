//Dart import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

//Third party library import
import 'package:provider/provider.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

//Local import
import 'package:simply_better_delivery/state_management/main.dart';
import 'package:simply_better_delivery/model/address_with_latlng.dart';

class ProfileSetupPage extends StatefulWidget {
  final MainStateManager manager;

  ProfileSetupPage({Key key, this.manager}) : super(key: key);

  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  PageController _pageController = PageController();
  TextEditingController _nameTextEditingController = TextEditingController();
  TextEditingController _passwordTextEditingController =
      TextEditingController();
  TextEditingController _genderTextEditingController = TextEditingController();
  TextEditingController _dateOfBirthTextEditingController =
      TextEditingController();
  TextEditingController _addressTextEditingController = TextEditingController();
  TextEditingController _buildingNoTextEditingController =
      TextEditingController();

  bool _signUpLoading = false;
  bool _signUpSuccessful = false;

  _buildConfirmationPage(
      MainStateManager manager, double width, double height) {
    return WillPopScope(
      onWillPop: () {
        return _pageController.previousPage(
            duration: Duration(seconds: 1), curve: Curves.ease);
      },
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(top: height * 0.1),
            height: height * 0.8,
            width: width * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Confirm details',
                  style: Theme.of(context).textTheme.headline1,
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Name:',
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 20),
                          ),
                          Text(
                            _nameTextEditingController.text,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 15),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Date of birth:',
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 20),
                          ),
                          Text(
                            '${_dateOfBirthTextEditingController.text}',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 15),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Shipping Address:',
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 20),
                          ),
                          Text(
                            '${manager.tempAddressString}',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 15),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        color: Theme.of(context).primaryColor,
                        child: Container(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'Back',
                              style: TextStyle(
                                  color: Theme.of(context).backgroundColor),
                            )),
                        onPressed: () {
                          _pageController.previousPage(
                              duration: Duration(seconds: 1),
                              curve: Curves.ease);
                        },
                      ),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        color: Theme.of(context).primaryColor,
                        child: Container(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                                color: Theme.of(context).backgroundColor
                                   ),
                          ),
                        ),
                        onPressed:  () async {
                                setState(() {
                                  _signUpLoading = true;
                                });
                                await widget.manager
                                    .setUpProfile(
                                        context: context,
                                        name: _nameTextEditingController.text,
                                        email: '',
                                        password:
                                            _passwordTextEditingController.text,
                                        gender:
                                            _genderTextEditingController.text,
                                        dateOfBirth: _selectedDateOfBirth,
                                        contactNumber:
                                            manager.firebaseUser.phoneNumber,
                                        address:
                                            widget.manager.tempAddressString,
                                        addressWithLatLng:
                                        manager.currentAddress)
                                    .then((Map<String, dynamic>
                                        successInformation) {
                                  widget.manager.tempAddressString = '';
                                  if (successInformation['success']) {
                                    setState(() {
                                      _signUpLoading = false;
                                      _signUpSuccessful = true;
                                      manager.userHasProfileSubject.add(true);
                                      manager.userAuthSubject.add(true);
                                    });
                                  } else {
                                    setState(() {
                                      _signUpLoading = false;
                                    });
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('An Error Occurred!'),
                                            content: Text(
                                                successInformation['message']),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('Okay'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        });
                                  }
                                });
                              }
                          ,
                      ),
                    ],
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
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: StreamBuilder<Object>(
          stream: null,
          builder: (context, snapshot) {
            return Consumer(
              builder: (BuildContext context, MainStateManager manager, Widget child) {
                return WillPopScope(
                  onWillPop: () {
                    if (_signUpLoading) {
                      return;
                    }
                  },
                  child: Scaffold(
                      backgroundColor: Theme.of(context).backgroundColor,
                      body: _signUpLoading
                          ? Center(
                              child: Text(
                                'Signing up...',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            )
                          : Stack(
                              children: <Widget>[
                                _signUpSuccessful
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.check),
                                            Text(
                                              'Sign up successful! Please wait while we log you in!',
                                              style:
                                                  Theme.of(context).textTheme.headline3,
                                              textAlign: TextAlign.center,
                                            )
                                          ],
                                        ),
                                      )
                                    : PageView(
                                        physics: NeverScrollableScrollPhysics(),
                                        controller: _pageController,
                                        children: <Widget>[
                                          _SignUpName(
                                            controller: _pageController,
                                            nameTextEditingController:
                                                _nameTextEditingController,
                                          ),
                                          _SignUpPageGenderDob(
                                              controller: _pageController,
                                              genderTextEditingController:
                                                  _genderTextEditingController,
                                              dateOfBirthTextEditingController:
                                                  _dateOfBirthTextEditingController),
                                          _SignUpAddress(
                                            manager: manager,
                                            controller: _pageController,
                                            addressTextEditingController:
                                                _addressTextEditingController,
                                            buildingNoTextEditingController:
                                                _buildingNoTextEditingController,
                                          ),
                                          _buildConfirmationPage(
                                              manager, width, height),
                                        ],
                                      ),
                              ],
                            )),
                );
              },
            );
          }
        ),
      ),
    );
  }
}

/// Name , Email
class _SignUpName extends StatefulWidget {
  final PageController controller;
  final TextEditingController nameTextEditingController;

  _SignUpName({
    this.controller,
    this.nameTextEditingController,
  });

  @override
  State<StatefulWidget> createState() {
    return _SignUpNameState();
  }
}

class _SignUpNameState extends State<_SignUpName> {
  GlobalKey<FormState> _nameFormKey = GlobalKey<FormState>();
  FocusNode _nameFocusNode = FocusNode();

  _nextPage() {
    widget.controller
        .nextPage(duration: Duration(seconds: 1), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: EdgeInsets.only(top: height * 0.1),
          height: height * 0.8,
          width: width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'What\'s your name ?\n',
                maxLines: 3,
                style: Theme.of(context).textTheme.headline1,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Form(
                      key: _nameFormKey,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: TextFormField(
                          focusNode: _nameFocusNode,
                          controller: widget.nameTextEditingController,
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                          decoration: new InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Name',
                            hintStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                            icon: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Please enter name';
                            } else {
                              return null;
                            }
                          },
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (String term) {
                            if (!_nameFormKey.currentState.validate()) {
                              return;
                            }
                            FocusScope.of(context).unfocus();
                            _nextPage();
                          },
                        ),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0)),
                      color: Theme.of(context).primaryColor,
                      child: Container(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            'Next',
                            style: TextStyle(
                                color: Theme.of(context).backgroundColor),
                          )),
                      onPressed: () {
                        if (!_nameFormKey.currentState.validate()) {
                          return;
                        }
                        FocusScope.of(context).unfocus();
                        _nextPage();
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// GENDER DOB
DateTime _selectedDateOfBirth;

class _SignUpPageGenderDob extends StatefulWidget {
  final PageController controller;
  final TextEditingController genderTextEditingController;
  final TextEditingController dateOfBirthTextEditingController;

  _SignUpPageGenderDob(
      {this.controller,
      this.genderTextEditingController,
      this.dateOfBirthTextEditingController});

  @override
  State<StatefulWidget> createState() {
    return _SignUpPageGenderDobState();
  }
}

class _SignUpPageGenderDobState extends State<_SignUpPageGenderDob> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<bool> _previousPage() {
    return widget.controller
        .previousPage(duration: Duration(seconds: 1), curve: Curves.ease);
  }

  _nextPage() {
    widget.controller
        .nextPage(duration: Duration(seconds: 1), curve: Curves.ease);
  }

  void _openGenderPickerDialog(double height) {
    showDialog(
      context: context,
      builder: (context) => Theme(
          data: Theme.of(context)
              .copyWith(primaryColor: Theme.of(context).primaryColor),
          child: Dialog(
            child: Container(
              height: height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'You\'re a...',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).accentColor),
                  ),
                  ListView(
                    shrinkWrap: true,
                    children: ['Male', 'Female', 'Rather not say']
                        .map(
                          (item) => SimpleDialogOption(
                            child: Container(
                              height: height * 0.05,
                              child: Row(
                                children: <Widget>[
                                  item == 'Male'
                                      ? Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            color: Colors.blueAccent,
                                          ),
                                        )
                                      : item == 'Female'
                                          ? Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                color: Colors.pinkAccent,
                                              ),
                                            )
                                          : Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                color: Colors.grey,
                                              ),
                                            ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    item,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              widget.genderTextEditingController.text = item;
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  void _openDatePicker() {
    DateTime _dateTime = DateTime.now();

    if (Theme.of(context).platform == TargetPlatform.android) {
      showDatePicker(
              context: context,
              initialDate: _dateTime,
              firstDate: DateTime(1000),
              lastDate: DateTime(3000))
          .then((value) {
        _selectedDateOfBirth = value;
        widget.dateOfBirthTextEditingController.text =
            '${DateFormat('dd MMMM yyyy').format(_selectedDateOfBirth)}';
      });
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      CupertinoDatePicker(
        initialDateTime: _dateTime,
        onDateTimeChanged: (dateTime) {
          setState(() {
            _dateTime = dateTime;
            _selectedDateOfBirth = dateTime;
            widget.dateOfBirthTextEditingController.text =
                '${DateFormat('dd MMMM yyyy').format(_selectedDateOfBirth)}';
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _previousPage,
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(top: height * 0.1),
            height: height * 0.8,
            width: width * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'What\'s your gender and date of birth?\n',
                  maxLines: 3,
                  style: Theme.of(context).textTheme.headline1,
                ),
                Expanded(
                  flex: 1,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ///Gender
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: TextFormField(
                            controller: widget.genderTextEditingController,
                            readOnly: true,
                            onTap: () {
                              _openGenderPickerDialog(height);
                            },
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                            decoration: new InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Gender',
                              hintStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              icon: Icon(
                                Icons.people,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Please select gender';
                              } else {
                                return null;
                              }
                            },
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),

                        ///DOB
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: TextFormField(
                            controller: widget.dateOfBirthTextEditingController,
                            readOnly: true,
                            onTap: () {
                              _openDatePicker();
                            },
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                            decoration: new InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Date of birth',
                              hintStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              icon: Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Please select date of birth';
                              } else {
                                return null;
                              }
                            },
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        color: Theme.of(context).primaryColor,
                        child: Container(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'Back',
                              style: TextStyle(
                                  color: Theme.of(context).backgroundColor),
                            )),
                        onPressed: _previousPage,
                      ),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        color: Theme.of(context).primaryColor,
                        child: Container(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                  color: Theme.of(context).backgroundColor),
                            )),
                        onPressed: () {
                          if (!_formKey.currentState.validate()) {
                            return;
                          }
                          _nextPage();
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Home Address
class _SignUpAddress extends StatefulWidget {
  final PageController controller;
  final TextEditingController buildingNoTextEditingController;
  final TextEditingController addressTextEditingController;
  final MainStateManager manager;

  _SignUpAddress(
      {this.controller,
      this.addressTextEditingController,
      this.buildingNoTextEditingController,
      this.manager});

  @override
  State<StatefulWidget> createState() {
    return _SignUpAddressState();
  }
}

class _SignUpAddressState extends State<_SignUpAddress>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> _buildingNoFormKey = GlobalKey<FormState>();
  FocusNode _addressFocusNode = FocusNode();
  String _addressString;
  Location _location = new Location();
  bool _serviceEnabled, _manualAddressEntry = false;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  Future<bool> _previousPage() {
    return widget.controller
        .previousPage(duration: Duration(seconds: 1), curve: Curves.ease);
  }

  _nextPage() async {
    widget.manager.tempAddressString = _addressString;

    ///EMPTY MANUAL ADDRESS
    if (_manualAddressEntry) {
      if (!_addressFormKey.currentState.validate()) {
        return;
      }
    }
    FocusScope.of(context).unfocus();

    ///If user enters address manually
    if (_manualAddressEntry) {
      widget.manager.updateCurrentAddressCompleteString(
          '${widget.addressTextEditingController.text}');
      widget.manager.tempAddressString =
          widget.addressTextEditingController.text;
    } else
      widget.manager.updateCurrentAddressCompleteString('${_addressString}');

    if (_manualAddressEntry) {
      await _forwardGeocode(' ${widget.addressTextEditingController.text}')
          .then((address) {
        print(' forwardgeocode returns $address');
        if (address['address'] != 'error')
          widget.manager.currentAddress = _newAddressObject(
            address,
            (address['lat']),
            (address['lon']),
          );

        widget.manager.tempAddressString =
            widget.addressTextEditingController.text;
      });
    }
    widget.controller
        .nextPage(duration: Duration(seconds: 1), curve: Curves.ease);
  }

  ///Checks location Permission Granted
  void checksLocationPermission() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    print("permission granted? $_locationData");
  }

  ///Initialise Location
  Future _initializeLocation() async {
    _locationData = await _location.getLocation();
    await _reverseGeocode(_locationData.latitude, _locationData.longitude)
        .then((address) {
      print('reversegeocode.then $address');

      if (address['address'] != 'error') {
        widget.manager.currentAddress = _newAddressObject(
            address, _locationData.latitude, _locationData.longitude);
      } else {
        print('error ');

        _manualAddressEntry = true;
      }
    });
  }

  ///Creates AddressWithLatLng with Map
  AddressWithLatLng _newAddressObject(
      Map<String, dynamic> address, double lat, double lng) {
    _addressString =
        '${address['unitNo'] == null ? '' : '${address['unitNo'].toString()}, '}'
        '${address['road'] == null ? '' : '${address['road']},\n'}'
        '${address['neighbourhood'] == null ? '' : '${address['neighbourhood']},\n'}'
        '${address['suburb'] == null ? '' : '${address['suburb']}\n'}'
        '${address['postcode'] == null ? '' : '${address['postcode']}\n'}'
        '${address['city'] == null ? '' : '${address['city']},\n'}'
        '${address['state'] == null ? '' : '${address['state']}\n'}'
        '${address['country'] == null ? '' : '${address['country']}\n'}';
    print('ADDRESS STRING $_addressString');

    return AddressWithLatLng(
        city: address['city'],
        country: address['country'],
        countryCode: address['countryCode'],
        neighbourhood: address['neighbourhood'],
        postcode: address['postcode'],
        unitNumber: address['unitNo'].toString(),
        road: address['road'],
        suburb: address['suburb'],
        state: address['state'],
        completeAddressString: address['address'],
        lat: lat,
        lng: lng);
  }

  ///Forward Geocode
  ///Returns error if cannot detect house number && road && neighbourhood
  Future<Map> _forwardGeocode(String addressString) async {
    Geocoding geocoding = Geocoder.local;
    List<Address> results =
        await geocoding.findAddressesFromQuery(addressString);

    print('forwardGeocode results ${results[0].coordinates}');

    if (results[0].thoroughfare != null &&
        results[0].subThoroughfare != null &&
        results[0].subThoroughfare != null) {
      Map<String, dynamic> address = {
        'lat': results[0].coordinates.latitude,
        'lon': results[0].coordinates.longitude,
        'address': results[0].addressLine,
        'unitNo': results[0].subThoroughfare.toString(),
        'road': results[0].thoroughfare,
        'neighbourhood': results[0].subLocality,
        'city': results[0].locality,
        'suburb': results[0].subAdminArea,
        'state': results[0].adminArea,
        'postcode': results[0].postalCode,
        'country': results[0].countryName,
      };

      if (addressString.contains('Kuala Lumpur')) {
        address['state'] = 'Kuala Lumpur';
      } else if (addressString.contains('Selangor')) {
        address['state'] = 'Selangor';
      }

      print('forwardGeocode results ${address['state']}');

      print('address $address');
      return address;
    } else {
      return {'address': 'error'};
    }
  }

  /// Reverse Geocode
  /// Returns error if cannot detect road && neighbourhood , set manual address entry to true;
  Future<Map> _reverseGeocode(double lat, double lon) async {
    Geocoding geocoding = Geocoder.local;
    List<Address> results =
        await geocoding.findAddressesFromCoordinates(new Coordinates(lat, lon));

    if (results[0].thoroughfare != null && results[0].subThoroughfare != null) {
      Map<String, dynamic> address = {
        'lat': lat,
        'lon': lon,
        'address': results[0].addressLine,
        'unitNo': results[0].subThoroughfare,
        'road': results[0].thoroughfare,
        'neighbourhood': results[0].subLocality,
        'city': results[0].locality,
        'suburb': results[0].subAdminArea,
        'state': results[0].adminArea,
        'postcode': results[0].postalCode,
        'country': results[0].countryName,
      };
      return address;
    } else {
      Map<String, dynamic> address = {'address': 'error'};
      _manualAddressEntry = true;
      return address;
    }
  }

  @override
  void initState() {
    checksLocationPermission();
    _initializeLocation().then((value) {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _previousPage,
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(top: height * 0.1),
            width: width * 0.8,
            height: height * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ///Title
                _manualAddressEntry
                    ? Text(
                        "Oops ! We couldn't locate you, tell us where we should deliver your goods !\n\n",
                        maxLines: 3,
                        style: Theme.of(context).textTheme.headline1,
                      )
                    : Text(
                        'Is this where you want us to deliver your fresh goods?\n\n',
                        maxLines: null,
                        style: Theme.of(context).textTheme.headline1,
                      ),

                /// Manual Entry of Address
                widget.manager.currentAddress.road == null ||
                        _manualAddressEntry
                    ? Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Form(
                            key: _buildingNoFormKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Form(
                                  key: _addressFormKey,
                                  child: Container(
                                    height: height * 0.2,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    child: TextFormField(
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      focusNode: _addressFocusNode,
                                      controller:
                                          widget.addressTextEditingController,
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor),
                                      decoration: new InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Address',
                                        hintStyle: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                        icon: Icon(
                                          Icons.map,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return '';
                                        } else {
                                          return null;
                                        }
                                      },
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (String term) {
                                        if (!_buildingNoFormKey.currentState
                                            .validate()) {
                                          return;
                                        }
                                        if (!_addressFormKey.currentState
                                            .validate()) {
                                          return;
                                        }
                                        FocusScope.of(context).unfocus();
                                        _nextPage();
                                      },
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(),

                /// Reverse GeoCoded address
                widget.manager.currentAddress.road != null &&
                        !_manualAddressEntry
                    ? Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _manualAddressEntry = !_manualAddressEntry;
                              if (_manualAddressEntry) {
                                widget.addressTextEditingController.text =
                                    _addressString;
                              }
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: _addressString != null
                                ? Text(_addressString,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold))
                                : Center(
                                    child: Container(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ))),
                          ),
                        ),
                      )
                    : Container(),

                ///Page Navi
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        color: Theme.of(context).primaryColor,
                        child: Container(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'Back',
                              style: TextStyle(
                                  color: Theme.of(context).backgroundColor),
                            )),
                        onPressed: _previousPage,
                      ),
                      _addressString != null
                          ? FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.0)),
                              color: Theme.of(context).primaryColor,
                              child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Text(
                                    'Next',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).backgroundColor),
                                  )),
                              onPressed: () async {
                                _nextPage();
                              },
                            )
                          : Container(),
                    ],
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
  bool get wantKeepAlive => true;
}
