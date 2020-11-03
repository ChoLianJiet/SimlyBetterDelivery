//Dart import
import 'package:flutter/material.dart';

//Third party library import
import 'package:cloud_firestore/cloud_firestore.dart';

//Local import


class TotalItem {
  Map<String, TotalItemProduct> productMap;

  TotalItem({@required this.productMap});

}

class TotalItemProduct {
  String productName;
  List<String> productImages;
  Map<String, TotalItemOption> options;

  TotalItemProduct({
    @required this.productName,
    @required this.productImages,
    @required this.options,
  });
}

class TotalItemOption {
  num groupPrice;
  int index;
  bool isLate;
  bool isOrdered;
  num quantity;
  num standardPrice;

  TotalItemOption({
    @required this.groupPrice,
    @required this.index,
    @required this.isLate,
    @required this.isOrdered,
    @required this.quantity,
    @required this.standardPrice,
  });
}
