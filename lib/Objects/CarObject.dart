import 'dart:io';

class CarObject {
  String id, imageName, carBrand, carModel, carType, carNumber;
  File carImage;

  CarObject({
    this.id,
    this.imageName,
    this.carBrand,
    this.carModel,
    this.carType,
    this.carNumber,
    this.carImage,
  });
}
