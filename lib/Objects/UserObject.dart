import 'dart:io';

class UserObject {
  String userUID,
      userId,
      // userName,
      userPhoneNumber,
      userEmail,
      userName,
      userFirstName,
      userLastName,
      userPassword,
      userImageName,
      userImageLink,
      userConfirmPassword,
      userAddress,
      area,
      city;
  double weight, height;
  bool subscription;

  File userImage;

  UserObject({
    this.userUID,
    this.userId,
    // this.userName,
    this.userPhoneNumber,
    this.userEmail,
    this.userName,
    this.userFirstName,
    this.userLastName,
    this.userPassword,
    this.userAddress,
    this.userImageLink,
    this.userImageName,
    this.userConfirmPassword,
    this.userImage,
    this.height,
    this.weight,
    this.subscription,
    this.area,
    this.city,
  });

  String getCustomerName() {
    return '$userFirstName $userLastName';
  }
}
