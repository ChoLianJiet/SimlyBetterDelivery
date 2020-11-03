//Dart import
import 'package:flutter/material.dart';

//Third party library import
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Local import
import 'package:simply_better_delivery/model/driver.dart';
import 'package:simply_better_delivery/model/address_with_latlng.dart';
import 'package:simply_better_delivery/model/to_deliver_item.dart';

mixin AssistantManager on ChangeNotifier {
  ///Firebase auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///Firebase user
  FirebaseUser _firebaseUser;

  FirebaseUser get firebaseUser {
    return _firebaseUser;
  }

  ///User object
  Driver _driver;

  Driver get driver {
    return _driver;
  }

  ///Firestore reference
  final CollectionReference _driverCollectionReference =
      Firestore.instance.collection('drivers');
  final CollectionReference _userCollectionReference =
      Firestore.instance.collection('users');
  final CollectionReference _deliveryCollectionReference =
      Firestore.instance.collection('delivery');
}

mixin AuthManager on AssistantManager {
  ///Stream to check user's authentication
  PublishSubject<bool> _userAuthSubject = PublishSubject();

  PublishSubject<bool> get userAuthSubject {
    return _userAuthSubject;
  }

  ///Stream to check user has profile
  PublishSubject<bool> _userHasProfileSubject = PublishSubject();

  PublishSubject<bool> get userHasProfileSubject {
    return _userHasProfileSubject;
  }

  bool _verifyLoading = false;

  bool get verifyLoading {
    return _verifyLoading;
  }

  void setVerifyLoading(bool loading) {
    _verifyLoading = loading;
    notifyListeners();
  }

  String _smsVerificationCode;
  String _smsVerificationId;

  bool _needCode = false;

  bool get needCode {
    return _needCode;
  }

  set needCode(bool value) {
    _needCode = value;
  }

  bool _hasProfile = false;

  bool get hasProfile {
    return _hasProfile;
  }

  bool _verificationSuccessful = true;

  bool get verificationSuccessful {
    return _verificationSuccessful;
  }

  Future verifyPhoneNumber(BuildContext context, phoneAuthController) async {
    String phoneNumber = "+60" + phoneAuthController.text.toString();
    print(phoneNumber);
    await _auth
        .verifyPhoneNumber(
            phoneNumber: phoneNumber,
            timeout: Duration(seconds: 0),
            verificationCompleted: (authCredential) =>
                _verificationComplete(authCredential, context),
            verificationFailed: (authException) =>
                _verificationFailed(authException, context),
            codeAutoRetrievalTimeout: (verificationId) =>
                _codeAutoRetrievalTimeout(verificationId),
            // called when the SMS code is sent
            codeSent: (verificationId, [code]) =>
                _smsCodeSent(verificationId, [code]))
        .then((_) {
      if (_verificationSuccessful == false) {
        _needCode = false;
        _verifyLoading = false;
        notifyListeners();
      }
    });
    return;
  }

  /// will get an AuthCredential object that will help with logging into Firebase.
  _verificationComplete(
      AuthCredential authCredential, BuildContext context) async {
    await _auth.signInWithCredential(authCredential).then((authResult) {
      _firebaseUser = authResult.user;
      _verificationSuccessful = true;
      userAuthSubject.add(true);
      _verifyLoading = false;
    });
  }

  _smsCodeSent(String verificationId, List<int> code) {
    // set the verification code so that we can use it to log the user in
    _needCode = true;
    _smsVerificationId = verificationId;
    _smsVerificationCode = code.join();
    print('haha');
    print(_smsVerificationId);
    notifyListeners();
  }

  _verificationFailed(AuthException authException, BuildContext context) {
    _needCode = false;
    _verifyLoading = false;
    _verificationSuccessful = false;
    showDialog(
      builder: (context) {
        notifyListeners();
        return AlertDialog(
            title: Text('Fail to verify!'),
            content: Text('${authException.message}'));
      },
      context: context,
    );
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    // set the verification code so that we can use it to log the user in
    _smsVerificationId = verificationId;
    _verifyLoading = false;
    notifyListeners();
  }

  Future signInWithPhoneNumber(context, code) async {
    _verifyLoading = true;
    try {
      AuthCredential authCredential = PhoneAuthProvider.getCredential(
          verificationId: _smsVerificationId, smsCode: code);
      await FirebaseAuth.instance
          .signInWithCredential(authCredential)
          .then((authResult) {
        _firebaseUser = authResult.user;
        _verificationSuccessful = true;
        userAuthSubject.add(true);
        notifyListeners();
      });
    } catch (e) {
      String errorMessage;
      print(e);
      if (e.toString().contains('ERROR_INVALID_VERIFICATION_CODE')) {
        errorMessage = 'Please enter a valid verification code';
      }
      showDialog(
          context: context,
          child: AlertDialog(
              title: Text('Fail to verify!'),
              content: Text(
                  '${e.toString()}\n$_smsVerificationCode\n$_smsVerificationId')));
    }
    _verifyLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> setUpProfile({
    BuildContext context,
    String name,
    String email,
    String password,
    String gender,
    DateTime dateOfBirth,
    String address,
    AddressWithLatLng addressWithLatLng,
    String city,
    String postcode,
    String state,
    String country,
    String contactNumber,
  }) async {
    bool success = false;
    String message = 'Something went wrong';

    await _driverCollectionReference.document(_firebaseUser.uid).setData({
      'time_created': _firebaseUser.metadata.creationTime,
      'name': name,
      'email': email,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'address_map': {
        'address': address,
        'address_details': AddressWithLatLng.toMap(addressWithLatLng),
      },
      'contact_number': contactNumber,
      'in_transit': false,
      'jobs_on_hand': [],
      'total_deliveries_delivered': 0,
      'total_earned': 0,
      'total_claimed': 0,
      'role': 'Driver',
    }).then((_) async {
      _driver = Driver(
          timeCreated: _firebaseUser.metadata.creationTime,
          name: name,
          gender: gender,
          dateOfBirth: dateOfBirth,
          address: DriverAddress(
            address: address,
            addressDetails: addressWithLatLng,
          ),
          contactNumber: contactNumber,
          driverId: _firebaseUser.uid);
    }).whenComplete(() {
      success = true;
      message = "You're all set !";
    });

    notifyListeners();
    return {'success': success, 'message': message};
  }

  Future getDriverProfile() async {
    await _driverCollectionReference
        .document(_firebaseUser.uid)
        .get()
        .then((value) async {
      if (value.data == null) {
        _hasProfile = false;

        _userHasProfileSubject.add(false);
      } else {
        _driver = Driver.fromFirestore(value);
      }
    });
  }

  ///Auto login
  Future autoAuthenticate() async {
    _firebaseUser = await _auth.currentUser();
    try {
      if (_firebaseUser != null) {
        await _driverCollectionReference
            .document(_firebaseUser.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          _driver = Driver.fromFirestore(documentSnapshot);
          if (documentSnapshot.data == null) {
            _hasProfile = false;
            _userHasProfileSubject.add(false);
          } else {
            _hasProfile = true;
            _userHasProfileSubject.add(true);
          }
          _userAuthSubject.add(true);
        });
      } else {
        _userAuthSubject.add(false);
      }
    } catch (e) {
      _userAuthSubject.add(false);
    }
  }

  Future logout() async {
    _verificationSuccessful = false;
    await _auth.signOut().whenComplete(() async {
      _userAuthSubject.add(false);
      _firebaseUser = null;
    });
  }
}

mixin LocationManager on AssistantManager {
  String _tempAddressString;

  String get tempAddressString {
    return _tempAddressString;
  }

  set tempAddressString(String address) {
    _tempAddressString = address;
    notifyListeners();
  }

  AddressWithLatLng _currentAddress = AddressWithLatLng(
    city: '',
    state: '',
    country: '',
    countryCode: '',
    neighbourhood: '',
    postcode: '',
    suburb: '',
    road: '',
    unitNumber: '',
  );

  AddressWithLatLng get currentAddress {
    return _currentAddress;
  }

  set currentAddress(AddressWithLatLng address) {
    _currentAddress = address;
    notifyListeners();
  }

  void updateCurrentAddressCompleteString(String addressString) {
    _currentAddress.completeAddressString = addressString;
    notifyListeners();
  }
}

mixin DeliveryManager on AssistantManager {
  Future startToDeliver(QuerySnapshot tripQuerySnapshot) async {
    WriteBatch batch = Firestore.instance.batch();
    DocumentReference driverDocumentReference =
        _driverCollectionReference.document(_driver.driverId);
    batch.updateData(driverDocumentReference, {'in_transit': true});
    for (int index = 0; index < tripQuerySnapshot.documents.length; index++) {
      DocumentSnapshot documentSnapshot = tripQuerySnapshot.documents[index];
      DocumentReference tripDocumentReference = _driverCollectionReference
          .document(_driver.driverId)
          .collection('trips')
          .document(documentSnapshot.documentID);
      batch.updateData(
          tripDocumentReference, {'delivered_out_date': DateTime.now()});
      List<String> deliveryIdList = [];
      documentSnapshot.data['waypoints'].forEach((dynamic waypoint) {
        deliveryIdList.addAll(waypoint['delivery_id_list'].cast<String>());
      });
      for (int i = 0; i < deliveryIdList.length; i++) {
        String deliveryId = deliveryIdList[i];
        String userId = deliveryId.split('_').first;
        String orderId = deliveryId.split('_').sublist(0, 2).join('_');
        DocumentReference deliveryDocumentReference =
            _deliveryCollectionReference.document(deliveryId);
        batch.updateData(deliveryDocumentReference, {
          'delivered_out_date': DateTime.now(),
        });
        DocumentReference deliveryStatusDocumentReference =
            _deliveryCollectionReference
                .document(deliveryId)
                .collection('statuses')
                .document();
        batch.setData(deliveryStatusDocumentReference, {
          'body':
              'Your order (Order ID: ${orderId.split('_').last}) is out for delivery',
          'handed_to': {
            'name': _driver.name,
            'role': 'Driver',
          },
          'location': {
            'address':
                '61, Jalan Sb Indah 3/7, Taman Sungai Besi Indah, 43300 Seri Kembangan, Selangor Malaysia',
            'lat': 3.03237,
            'lng': 101.722984,
          },
          'require_fcm': true,
          'status': 'out_for_delivery',
          'time_created': DateTime.now(),
          'title': 'Order Out For Delivery',
          'order_id': orderId,
        });
      }
    }
    await batch.commit();
  }

  Future undeliverDelivery(WaypointDetail waypointDetail, String reason) async {
    WriteBatch batch = Firestore.instance.batch();
    DocumentReference tripDocumentReference = _driverCollectionReference
        .document(_driver.driverId)
        .collection('trips')
        .document(waypointDetail.tripId);
    await tripDocumentReference
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      List<dynamic> waypoints = documentSnapshot.data['waypoints'];
      waypoints.forEach((dynamic waypoint) {
        if (waypoint['waypoint_index'] == waypointDetail.waypointIndex) {
          waypoint['completed_date'] = DateTime.now();
          waypoint['delivered_successfully'] = false;
          waypoint['failed_reason'] = reason;
        }
      });
      if (waypoints.any((dynamic waypoint) {
        return waypoint['completed_date'] == null;
      })) {
        batch.updateData(tripDocumentReference, {'waypoints': waypoints});
      } else {
        batch.updateData(
            tripDocumentReference, {'waypoints': waypoints, 'completed': true});
        DocumentReference driverDocumentReference =
            _driverCollectionReference.document(_driver.driverId);
        await driverDocumentReference
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          List<dynamic> jobsOnHandList = documentSnapshot.data['jobs_on_hand'];
          jobsOnHandList.remove(waypointDetail.tripId);
          if (jobsOnHandList.isEmpty) {
            batch.updateData(driverDocumentReference,
                {'jobs_on_hand': jobsOnHandList, 'in_transit': false});
          } else {
            batch.updateData(
                driverDocumentReference, {'jobs_on_hand': jobsOnHandList});
          }
        });
      }
    });
    for (int i = 0; i < waypointDetail.deliveryIdList.length; i++) {
      String deliveryId = waypointDetail.deliveryIdList[i];
      String userId = deliveryId.split('_').first;
      String orderId = deliveryId.split('_').sublist(0, 2).join('_');
      DocumentReference deliveryStatusDocumentReference =
          _deliveryCollectionReference
              .document(deliveryId)
              .collection('statuses')
              .document();
      batch.setData(deliveryStatusDocumentReference, {
        'body':
            'Oops! You missed your parcel (Order ID: ${orderId.split('_').last})',
        'handed_to': {
          'name': _driver.name,
          'role': 'Driver',
        },
        'location': {
          'address': waypointDetail.address.address,
          'lat': waypointDetail.address.addressDetails.lat,
          'lng': waypointDetail.address.addressDetails.lng,
        },
        'reason': reason,
        'require_fcm': true,
        'status': 'not_delivered',
        'time_created': DateTime.now(),
        'title': 'Order Not Delivered',
        'reassigned_delivery_date': DateTime.now().add(Duration(days: 1)),
        'order_id': orderId,
      });

      ///Creating new Delivery
      int deliveryNumber =
          int.tryParse(deliveryId.split('_').last.replaceAll('D', ''));
      String newDeliveryId = '${orderId}_D${deliveryNumber + 1}';
      DocumentSnapshot documentSnapshot =
          await _deliveryCollectionReference.document(deliveryId).get();
      Map<String, dynamic> documentData = documentSnapshot.data;
      documentData['delivered_out_date'] = null;
      documentData['driver'] = null;
      documentData['expected_delivery_date'] =
          DateTime.now().add(Duration(days: 1));
      documentData['time_created'] = DateTime.now();
      DocumentReference newDeliveryDocumentReference =
          _deliveryCollectionReference.document(newDeliveryId);
      batch.setData(newDeliveryDocumentReference, documentData);
      batch.updateData(
          _userCollectionReference
              .document(userId)
              .collection('orders')
              .document(orderId),
          {
            'delivery_id_list': FieldValue.arrayUnion([
              {
                'delivery_id': newDeliveryId,
                'expected_delivery_date': DateTime.now().add(Duration(days: 1)),
              }
            ]),
          });
    }
    await batch.commit();
  }

  Future completeDelivery(WaypointDetail waypointDetail) async {
    WriteBatch batch = Firestore.instance.batch();
    DocumentReference tripDocumentReference = _driverCollectionReference
        .document(_driver.driverId)
        .collection('trips')
        .document(waypointDetail.tripId);
    await tripDocumentReference
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      List<dynamic> waypoints = documentSnapshot.data['waypoints'];
      waypoints.forEach((dynamic waypoint) {
        if (waypoint['waypoint_index'] == waypointDetail.waypointIndex) {
          waypoint['completed_date'] = DateTime.now();
          waypoint['delivered_successfully'] = true;
        }
      });
      DocumentReference driverDocumentReference =
          _driverCollectionReference.document(_driver.driverId);
      await driverDocumentReference
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        num totalDeliveriesDelivered =
            documentSnapshot.data['total_deliveries_delivered'];
        totalDeliveriesDelivered = totalDeliveriesDelivered + 1;

        if (waypoints.any((dynamic waypoint) {
          return waypoint['completed_date'] == null;
        })) {
          batch.updateData(tripDocumentReference, {'waypoints': waypoints});
          batch.updateData(driverDocumentReference,
              {'total_deliveries_delivered': totalDeliveriesDelivered});
        } else {
          batch.updateData(tripDocumentReference,
              {'waypoints': waypoints, 'completed': true});

          List<dynamic> jobsOnHandList = documentSnapshot.data['jobs_on_hand'];
          jobsOnHandList.remove(waypointDetail.tripId);
          if (jobsOnHandList.isEmpty) {
            batch.updateData(driverDocumentReference, {
              'jobs_on_hand': jobsOnHandList,
              'in_transit': false,
              'total_deliveries_delivered': totalDeliveriesDelivered
            });
          } else {
            batch.updateData(driverDocumentReference, {
              'jobs_on_hand': jobsOnHandList,
              'total_deliveries_delivered': totalDeliveriesDelivered
            });
          }
        }
      });
    });
    for (int i = 0; i < waypointDetail.deliveryIdList.length; i++) {
      String deliveryId = waypointDetail.deliveryIdList[i];
      String userId = deliveryId.split('_').first;
      String orderId = deliveryId.split('_').sublist(0, 2).join('_');
      DocumentReference deliveryStatusDocumentReference =
          _deliveryCollectionReference
              .document(deliveryId)
              .collection('statuses')
              .document();
      batch.setData(deliveryStatusDocumentReference, {
        'body':
            'Your order (Order ID: ${orderId.split('_').last}) has been delivered to you',
        'handed_to': {
          'name': waypointDetail.receiver.name,
          'role': 'Customer',
        },
        'location': {
          'address': waypointDetail.address.address,
          'lat': waypointDetail.address.addressDetails.lat,
          'lng': waypointDetail.address.addressDetails.lng,
        },
        'require_fcm': true,
        'status': 'delivered',
        'time_created': DateTime.now(),
        'title': 'Order Delivered',
        'order_id': orderId,
      });
    }
    await batch.commit();
  }
}
