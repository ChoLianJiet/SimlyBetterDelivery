//Dart import
import 'package:flutter/material.dart';
import 'dart:collection';

//Third party library import
import 'package:cloud_firestore/cloud_firestore.dart';

//Local import
import 'package:simply_better_delivery/model/address_with_latlng.dart';

class WaypointDetail {
  String tripId;
  List<String> deliveryIdList;
  Receiver receiver;
  ToDeliverItemAddress address;
  Duration duration;
  num distance;
  int waypointIndex;
  DateTime completedDate;
  bool deliveredSuccessfully;
  String failedReason;
  List<ToDeliverItem> toDeliverItemList;
  num earned;
  bool claimed;
  List<String> noteList;

  WaypointDetail({
    @required this.tripId,
    @required this.receiver,
    @required this.address,
    @required this.duration,
    @required this.distance,
    @required this.waypointIndex,
    @required this.completedDate,
    @required this.deliveredSuccessfully,
    @required this.failedReason,
    @required this.toDeliverItemList,
    @required this.deliveryIdList,
    @required this.earned,
    @required this.claimed,
    @required this.noteList,
  });

  factory WaypointDetail.fromFirestore(
      String documentId, dynamic waypointDetails) {
    List<ToDeliverItem> toDeliverItemList = [];
//    Map<String, ToDeliverItem> orderList = {};
    waypointDetails['order_map_list']
        .forEach((dynamic toDeliverItemMap) {
      ToDeliverItem toDeliverItem = ToDeliverItem(deliveryId: toDeliverItemMap['delivery_id'], orderList: {});
          toDeliverItemMap['order_list'].forEach((dynamic productId, dynamic orderItemMap) {
            orderItemMap['options'].forEach((dynamic option, dynamic optionValue) {
              ToDeliverItemDetail toDeliverItemDetail;
              if (toDeliverItem.orderList[productId] == null) {
                toDeliverItemDetail = ToDeliverItemDetail(
                  discountPriceBy: orderItemMap['discount_price_by'],
                  isGroupAchieved: orderItemMap['is_group_achieved'],
                  merchant: orderItemMap['merchant'],
                  options: {
                    option: ToDeliverItemDetailOption(
                      groupPrice: optionValue['group_price'] as num,
                      index: optionValue['index'] as num,
                      isLate: optionValue['is_late'] as bool,
                      isOrdered: optionValue['is_ordered'] as bool,
                      quantity: optionValue['quantity'] as num,
                      standardPrice: optionValue['standard_price'] as num,
                    ),
                  },
                  productImages: orderItemMap['product_images'].cast<String>(),
                  productName: orderItemMap['product_name'],
                  frozen: orderItemMap['frozen'],
                  chilled: orderItemMap['chilled'],
                  halal: orderItemMap['halal'],
                );
              } else {
                toDeliverItemDetail = toDeliverItem.orderList[productId];
                if (toDeliverItemDetail.options[option] == null) {
                  toDeliverItemDetail.options[option] = ToDeliverItemDetailOption(
                    groupPrice: optionValue['group_price'] as num,
                    index: optionValue['index'] as num,
                    isLate: optionValue['is_late'] as bool,
                    isOrdered: optionValue['is_ordered'] as bool,
                    quantity: optionValue['quantity'] as num,
                    standardPrice: optionValue['standard_price'] as num,
                  );
                  var sortedKeys = toDeliverItemDetail.options.keys.toList()
                    ..sort((k1, k2) => toDeliverItemDetail.options[k1].index
                        .compareTo(toDeliverItemDetail.options[k2].index));
                  LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
                      key: (k) => k, value: (k) => toDeliverItemDetail.options[k]);
                  toDeliverItemDetail.options =
                      sortedMap.cast<String, ToDeliverItemDetailOption>();
                } else {
                  toDeliverItemDetail.options[option].quantity =
                      toDeliverItemDetail.options[option].quantity +
                          optionValue['quantity'];
                }
              }
              toDeliverItem.orderList.putIfAbsent(productId, () => toDeliverItemDetail);
            });
          });
      toDeliverItemList.add(toDeliverItem);
    });
//    waypointDetails['order_map_list']
//        .forEach((String productId, dynamic orderItemMap) {
//      orderItemMap['options'].forEach((dynamic option, dynamic optionValue) {
//        ToDeliverItemDetail toDeliverItemDetail;
//        if (orderList[productId] == null) {
//          toDeliverItemDetail = ToDeliverItemDetail(
//            discountPriceBy: orderItemMap['discount_price_by'],
//            isGroupAchieved: orderItemMap['is_group_achieved'],
//            merchant: orderItemMap['merchant'],
//            options: {
//              option: ToDeliverItemDetailOption(
//                groupPrice: optionValue['group_price'] as num,
//                index: optionValue['index'] as num,
//                isLate: optionValue['is_late'] as bool,
//                isOrdered: optionValue['is_ordered'] as bool,
//                quantity: optionValue['quantity'] as num,
//                standardPrice: optionValue['standard_price'] as num,
//              ),
//            },
//            productImages: orderItemMap['product_images'].cast<String>(),
//            productName: orderItemMap['product_name'],
//            frozen: orderItemMap['frozen'],
//            chilled: orderItemMap['chilled'],
//            halal: orderItemMap['halal'],
//          );
//        } else {
//          toDeliverItemDetail = orderList[productId];
//          if (toDeliverItemDetail.options[option] == null) {
//            toDeliverItemDetail.options[option] = ToDeliverItemDetailOption(
//              groupPrice: optionValue['group_price'] as num,
//              index: optionValue['index'] as num,
//              isLate: optionValue['is_late'] as bool,
//              isOrdered: optionValue['is_ordered'] as bool,
//              quantity: optionValue['quantity'] as num,
//              standardPrice: optionValue['standard_price'] as num,
//            );
//            var sortedKeys = toDeliverItemDetail.options.keys.toList()
//              ..sort((k1, k2) => toDeliverItemDetail.options[k1].index
//                  .compareTo(toDeliverItemDetail.options[k2].index));
//            LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
//                key: (k) => k, value: (k) => toDeliverItemDetail.options[k]);
//            toDeliverItemDetail.options =
//                sortedMap.cast<String, ToDeliverItemDetailOption>();
//          } else {
//            toDeliverItemDetail.options[option].quantity =
//                toDeliverItemDetail.options[option].quantity +
//                    optionValue['quantity'];
//          }
//        }
//        orderList.putIfAbsent(productId, () => toDeliverItemDetail);
//      });
//    });
    Receiver receiver = Receiver(
        contactNumber: waypointDetails['receiver']['contact_number'],
        name: waypointDetails['receiver']['name']);

    AddressWithLatLng addressWithLatLng = AddressWithLatLng(
      city: waypointDetails['address_details']['city'],
      completeAddressString: waypointDetails['address_details']
          ['completeAddress'],
      country: waypointDetails['address_details']['country'],
      countryCode: waypointDetails['address_details']['countryCode'],
      lat: waypointDetails['lat'],
      lng: waypointDetails['lng'],
      neighbourhood: waypointDetails['address_details']['neighbourhood'],
      postcode: waypointDetails['address_details']['postcode'],
      road: waypointDetails['address_details']['road'],
      state: waypointDetails['address_details']['state'],
      suburb: waypointDetails['address_details']['suburb'],
      unitNumber: waypointDetails['address_details']['unitNumber'],
    );
    return WaypointDetail(
      tripId: documentId,
      address: ToDeliverItemAddress(
          address: waypointDetails['address'],
          addressDetails: addressWithLatLng),
      receiver: receiver,
      duration: Duration(
          milliseconds: waypointDetails['duration'] == 0
              ? 0
              : (waypointDetails['duration'] * 1000).toInt()),
      distance: waypointDetails['distance'],
      waypointIndex: waypointDetails['waypoint_index'],
      completedDate: waypointDetails['completed_date'] == null
          ? null
          : waypointDetails['completed_date'].toDate(),
      deliveredSuccessfully: waypointDetails['delivered_successfully'],
      failedReason: waypointDetails['failed_reason'],
      toDeliverItemList: toDeliverItemList,
      deliveryIdList: waypointDetails['delivery_id_list'].cast<String>(),
      earned: waypointDetails['earned'],
      claimed: waypointDetails['claimed'],
      noteList: waypointDetails['note_list'].isEmpty? null : waypointDetails['note_list'].cast<String>(),
    );
  }
}

class ToDeliverItem {
  String deliveryId;
  Map<String,ToDeliverItemDetail> orderList;

  ToDeliverItem({@required this.deliveryId, @required this.orderList});
}

class ToDeliverItemDetail {
  num discountPriceBy;
  String merchant;
  Map<String, ToDeliverItemDetailOption> options;
  bool isGroupAchieved;
  List<String> productImages;
  String productName;
  bool frozen;
  bool chilled;
  bool halal;

  ToDeliverItemDetail({
    @required this.discountPriceBy,
    @required this.isGroupAchieved,
    @required this.merchant,
    @required this.options,
    @required this.productImages,
    @required this.productName,
    @required this.frozen,
    @required this.chilled,
    @required this.halal,
  });
}

class ToDeliverItemDetailOption {
  num groupPrice;
  int index;
  bool isLate;
  bool isOrdered;
  num quantity;
  num standardPrice;

  ToDeliverItemDetailOption({
    @required this.groupPrice,
    @required this.index,
    @required this.isLate,
    @required this.isOrdered,
    @required this.quantity,
    @required this.standardPrice,
  });
}

class Receiver {
  String contactNumber;
  String name;

  Receiver({
    @required this.contactNumber,
    @required this.name,
  });
}

class ToDeliverItemAddress {
  String address;
  AddressWithLatLng addressDetails;

  ToDeliverItemAddress({
    @required this.address,
    @required this.addressDetails,
  });
}
