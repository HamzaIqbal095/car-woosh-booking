import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  Reference storageReference = FirebaseStorage.instance.ref();

  Future<bool> addCustomerImageToStorage(
      String customerUID, File customerImage) async {
    try {
      if (customerImage != null) {
        Reference ref = storageReference.child('Users').child(
            '$customerUID.${customerImage.path.split('/').last.split('.').last}');
        final UploadTask uploadTask = ref.putFile(
          customerImage,
          SettableMetadata(
            contentLanguage: 'en',
            customMetadata: <String, String>{'activity': 'test'},
          ),
        );

        // if (uploadTask.isSuccessful) {
        return true;
        // }
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> addCarImageToStorage(File image) async {
    try {
      if (image != null) {
        Reference ref = storageReference
            .child('Cars')
            .child(FirebaseAuth.instance.currentUser.uid)
            .child(image.path.split('/').last);
        final UploadTask uploadTask = ref.putFile(
          image,
          SettableMetadata(
            contentLanguage: 'en',
            customMetadata: <String, String>{'activity': 'test'},
          ),
        );

        // if (uploadTask.isSuccessful) {
        return true;
        // }
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String> getUserImageLink(String imageName) async {
//    print('this is the image Name $imageName');
    Reference ref = storageReference.child('Users').child(imageName);
    String imageLink = await ref.getDownloadURL();
//    print(imageLink);

    return imageLink;
  }

  Future<String> getCarImageLink(String imageName) async {
   print('this is the image Name $imageName');
    Reference ref = storageReference
        .child('Cars')
        .child(FirebaseAuth.instance.currentUser.uid)
        .child(imageName);
    String imageLink = await ref.getDownloadURL();
   print("images links"+imageLink);

    if(imageLink == null){
      return null;
    }else{
      return imageLink;
    }
  }

  Future<String> getImageLink({String imageName, String folderName}) async {
    print('this is the image Name 1 $imageName');
    Reference ref = storageReference.child(folderName).child(imageName);
    String imageLink = await ref.getDownloadURL();
    // print(imageLink);
    return imageLink;
  }
}
