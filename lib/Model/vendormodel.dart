// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/widgets.dart';

class VendorModel {
  String open = "open";
  final String aadharCardNumber;
  final String businessAddress;
  final String businessCat;
  final String businessCity;
  final String businessImage;
  final double rating;
  final BusinessLocation businessLocation;
  final String businessMobileNumber;
  final String businessName;
  final String businessPinCode;
  final String businessSubCat;
  final String bussinesDesc;
  final int closeTime;
  final int adsBuyTimestamp;
  bool isAds;
  final String name;
  final int openTime;
  final String payment;
  final String paymentId;
  final String refCode;
  final String workingDay;
  String? userId;
  bool active = true;
  double distance = 0;

  final ValueNotifier<bool> book = ValueNotifier(false);
  final ValueNotifier<bool> visible = ValueNotifier(false);
  VendorModel({
    required this.aadharCardNumber,
    required this.businessAddress,
    required this.businessCat,
    required this.businessCity,
    required this.businessImage,
    required this.businessLocation,
    required this.businessMobileNumber,
    required this.businessName,
    required this.businessPinCode,
    required this.businessSubCat,
    required this.bussinesDesc,
    required this.closeTime,
    required this.isAds,
    required this.name,
    required this.openTime,
    required this.payment,
    required this.paymentId,
    required this.refCode,
    required this.workingDay,
    required this.userId,
    required this.active,
    required this.rating,
    required this.adsBuyTimestamp,
  });

  VendorModel copyWith({
    String? aadharCardNumber,
    String? businessAddress,
    String? businessCat,
    String? businessCity,
    String? businessImage,
    final String? coverImage,
    BusinessLocation? businessLocation,
    String? businessMobileNumber,
    String? businessName,
    String? businessPinCode,
    String? businessSubCat,
    String? bussinesDesc,
    int? closeTime,
    bool? isAds,
    String? name,
    int? openTime,
    String? payment,
    String? paymentId,
    String? refCode,
    String? workingDay,
    String? userId,
    bool? active,
  }) {
    return VendorModel(
      aadharCardNumber: aadharCardNumber ?? this.aadharCardNumber,
      businessAddress: businessAddress ?? this.businessAddress,
      businessCat: businessCat ?? this.businessCat,
      businessCity: businessCity ?? this.businessCity,
      businessImage: businessImage ?? this.businessImage,
      rating: rating ?? rating,
      adsBuyTimestamp: adsBuyTimestamp ?? adsBuyTimestamp,
      businessLocation: businessLocation ?? this.businessLocation,
      businessMobileNumber: businessMobileNumber ?? this.businessMobileNumber,
      businessName: businessName ?? this.businessName,
      businessPinCode: businessPinCode ?? this.businessPinCode,
      businessSubCat: businessSubCat ?? this.businessSubCat,
      bussinesDesc: bussinesDesc ?? this.bussinesDesc,
      closeTime: closeTime ?? this.closeTime,
      isAds: isAds ?? this.isAds,
      name: name ?? this.name,
      openTime: openTime ?? this.openTime,
      payment: payment ?? this.payment,
      paymentId: paymentId ?? this.paymentId,
      refCode: refCode ?? this.refCode,
      workingDay: workingDay ?? this.workingDay,
      userId: userId ?? this.userId,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'aadharCardNumber': aadharCardNumber,
      'businessAddress': businessAddress,
      'businessCat': businessCat,
      'businessCity': businessCity,
      'businessImage': businessImage,
      'businessLocation': businessLocation.toMap(),
      'businessMobileNumber': businessMobileNumber,
      'businessName': businessName,
      'businessPinCode': businessPinCode,
      'businessSubCat': businessSubCat,
      'bussinesDesc': bussinesDesc,
      'closeTime': closeTime,
      'isAds': isAds,
      'name': name,
      'openTime': openTime,
      'payment': payment,
      'paymentId': paymentId,
      'refCode': refCode,
      'workingDay': workingDay,
      'userId': userId,
      'active': active,
    };
  }

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel(
      aadharCardNumber: map['aadharCardNumber'] as String,
      adsBuyTimestamp: map['adsBuyTimestamp'] ?? 0,
      businessAddress: map['businessAddress'] as String,
      businessCat: map['businessCat'] as String,
      businessCity: map['businessCity'] as String,
      businessImage: map['businessImage'] as String,
      rating: double.parse(
          (map.containsKey("rating") ? map['rating'] : 0.0).toString()),
      businessLocation: BusinessLocation.fromMap(
          map['businessLocation'] as Map<String, dynamic>),
      businessMobileNumber: map['businessMobileNumber'] as String,
      businessName: map['businessName'] as String,
      businessPinCode: map['businessPinCode'] as String,
      businessSubCat: map['businessSubCat'] as String,
      bussinesDesc: map['bussinesDesc'] as String,
      closeTime: map['closeTime'] as int,
      isAds: map['isAds'] as bool,
      name: map['name'] as String,
      openTime: map['openTime'] as int,
      payment: map['payment'] as String,
      paymentId: map['paymentId'] as String,
      refCode: map['refCode'] as String,
      workingDay: map['workingDay'] as String,
      userId: map['userId'],
      active: map['active'],
    );
  }

  String toJson() => json.encode(toMap());

  factory VendorModel.fromJson(String source) =>
      VendorModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'VendorModel(aadharCardNumber: $aadharCardNumber, businessAddress: $businessAddress, businessCat: $businessCat, businessCity: $businessCity, businessImage: $businessImage, businessLocation: $businessLocation, businessMobileNumber: $businessMobileNumber, businessName: $businessName, businessPinCode: $businessPinCode, businessSubCat: $businessSubCat, bussinesDesc: $bussinesDesc, closeTime: $closeTime, isAds: $isAds, name: $name, openTime: $openTime, payment: $payment, paymentId: $paymentId, refCode: $refCode, workingDay: $workingDay, userId: $userId, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VendorModel &&
        other.aadharCardNumber == aadharCardNumber &&
        other.businessAddress == businessAddress &&
        other.businessCat == businessCat &&
        other.businessCity == businessCity &&
        other.businessImage == businessImage &&
        other.businessLocation == businessLocation &&
        other.businessMobileNumber == businessMobileNumber &&
        other.businessName == businessName &&
        other.businessPinCode == businessPinCode &&
        other.businessSubCat == businessSubCat &&
        other.bussinesDesc == bussinesDesc &&
        other.closeTime == closeTime &&
        other.isAds == isAds &&
        other.name == name &&
        other.openTime == openTime &&
        other.payment == payment &&
        other.paymentId == paymentId &&
        other.refCode == refCode &&
        other.workingDay == workingDay &&
        other.userId == userId &&
        other.active == active;
  }

  @override
  int get hashCode {
    return aadharCardNumber.hashCode ^
        businessAddress.hashCode ^
        businessCat.hashCode ^
        businessCity.hashCode ^
        businessImage.hashCode ^
        businessLocation.hashCode ^
        businessMobileNumber.hashCode ^
        businessName.hashCode ^
        businessPinCode.hashCode ^
        businessSubCat.hashCode ^
        bussinesDesc.hashCode ^
        closeTime.hashCode ^
        isAds.hashCode ^
        name.hashCode ^
        openTime.hashCode ^
        payment.hashCode ^
        paymentId.hashCode ^
        refCode.hashCode ^
        workingDay.hashCode ^
        userId.hashCode ^
        active.hashCode;
  }
}

class BusinessLocation {
  final double lat;
  final double long;
  BusinessLocation({
    required this.lat,
    required this.long,
  });

  BusinessLocation copyWith({
    double? lat,
    double? long,
  }) {
    return BusinessLocation(
      lat: lat ?? this.lat,
      long: long ?? this.long,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'lat': lat,
      'long': long,
    };
  }

  factory BusinessLocation.fromMap(Map<String, dynamic> map) {
    return BusinessLocation(
      lat: map['lat'].toDouble() as double,
      long: map['long'].toDouble() as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory BusinessLocation.fromJson(String source) =>
      BusinessLocation.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'BusinessLocation(lat: $lat, long: $long)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusinessLocation && other.lat == lat && other.long == long;
  }

  @override
  int get hashCode => lat.hashCode ^ long.hashCode;
}
