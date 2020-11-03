class AddressWithLatLng {
  String road,
      neighbourhood,
      suburb,
      city,
  state,
      postcode,
      country, unitNumber, completeAddressString,
      countryCode;

  double lat, lng;

  AddressWithLatLng({this.road,
    this.neighbourhood,
    this.suburb,
    this.city,
    this.state,
    this.country,
    this.countryCode,
    this.unitNumber, this.completeAddressString,
    this.lat, this.lng,

    this.postcode});


  static Map toMap(AddressWithLatLng address) {
    return {
      'unitNumber': address.unitNumber,
      'road': address.road,
      'neighbourhood': address.neighbourhood,
      'suburb': address.suburb,
      'postcode': address.postcode,
      'city': address.city,
      'state': address.state,
      'country': address.country,
      'completeAddress': address.completeAddressString,
      'lat': address.lat,
      'lng': address.lng
    };
  }
}
