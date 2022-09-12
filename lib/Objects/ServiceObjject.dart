import 'package:flutter/material.dart';
import 'package:woooosh/Objects/CarObject.dart';
import 'package:woooosh/Objects/CompanyObject.dart';
import 'package:woooosh/Objects/MyAddressObject.dart';
import 'package:woooosh/Objects/ServiceTypeObject.dart';

class ServiceObject {
  String id, paymentType;
  CarObject car;
  List<CarObject> selectedCars;
  List<ServiceTypeObject> selectedServiceTypes;
  ServiceTypeObject serviceType;
  double price;
  DateTime selectedDate;
  TimeOfDay selectedTime;
  MyAddressObject selectedAddress;
  String orderStatus;
  CompanyObject company;

  ServiceObject({
    this.id,
    this.paymentType,
    this.car,
    this.serviceType,
    this.price,
    this.selectedDate,
    this.selectedTime,
    this.selectedAddress,
    this.orderStatus,
    this.company,
    this.selectedCars,
    this.selectedServiceTypes,
  });
}
