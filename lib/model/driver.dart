//Dart import
import 'package:flutter/material.dart';

//Third party library import
import 'package:cloud_firestore/cloud_firestore.dart';

//Local import
import 'package:simply_better_delivery/model/address_with_latlng.dart';

class Driver {
  String driverId;
  String contactNumber;
  DateTime dateOfBirth;
  String gender;
  String name;
  DateTime timeCreated;
  DriverAddress address;

  Driver({
    @required this.driverId,
    @required this.contactNumber,
    @required this.dateOfBirth,
    @required this.gender,
    @required this.address,
    @required this.name,
    @required this.timeCreated,
  });

  factory Driver.fromFirestore(DocumentSnapshot documentSnapshot) {

    AddressWithLatLng addressWithLatLng = AddressWithLatLng(
      city: documentSnapshot.data['address_map']['address_details']['city'],
      completeAddressString: documentSnapshot.data['address_map']['address_details']['completeAddress'],
      country: documentSnapshot.data['address_map']['address_details']['country'],
      countryCode: documentSnapshot.data['address_map']['countryCode'],
      lat: documentSnapshot.data['address_map']['address_details']['lat'],
      lng: documentSnapshot.data['address_map']['address_details']['lng'],
      neighbourhood: documentSnapshot.data['address_map']['address_details']['neighbourhood'],
      postcode: documentSnapshot.data['address_map']['address_details']['postcode'],
      road: documentSnapshot.data['address_map']['address_details']['road'],
      state: documentSnapshot.data['address_map']['address_details']['state'],
      suburb: documentSnapshot.data['address_map']['address_details']['suburb'],
      unitNumber: documentSnapshot.data['address_map']['address_details']['unitNumber'],
    );

    return Driver(
      driverId: documentSnapshot.documentID,
      contactNumber: documentSnapshot.data['contact_number'],
      dateOfBirth: documentSnapshot.data['date_of_birth'].toDate(),
      gender: documentSnapshot.data['gender'],
      address: DriverAddress(address: documentSnapshot.data['address_map']['address'], addressDetails: addressWithLatLng),
      name: documentSnapshot.data['name'],
      timeCreated: documentSnapshot.data['time_created'].toDate(),
    );
  }
}

 class DriverAddress{
  String address;
  AddressWithLatLng addressDetails;

   DriverAddress({
     @required this.address,
     @required this.addressDetails,
   });
 }
