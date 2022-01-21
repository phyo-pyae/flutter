import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:phyopyaewa_logistics/services//firestore_path.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  FirebaseStorageService({@required this.uid}) : assert(uid != null);
  final String uid;

  /// Upload an avatar from file
  Future<String> uploadAvatar({
    @required File file,
  }) async =>
      await upload(
        file: file,
        path: FirestorePath.avatar(uid) + '/avatar.png',
        contentType: 'image/png',
      );
  // FirebaseStorage.instance.SettableMetadata metadata =
  // firebase_storage.SettableMetadata(
  //   cacheControl: 'max-age=60',
  //   customMetadata: <String, String>{
  //     'userId': 'ABC123',
  //   },
  // );
  /// Generic file upload for any [path] and [contentType]
  Future<String> upload({
    @required File file,
    @required String path,
    @required String contentType,
  }) async {
    print('uploading to: $path');
    final storageReference = FirebaseStorage.instance.ref().child(path);
    final uploadTask = storageReference.putFile(
        file, SettableMetadata(contentType: contentType));

    // if (snapshot.error != null) {
    //   print('upload error code: ${snapshot.error}');
    //   throw snapshot.error;
    // }
    try {
      final snapshot = await uploadTask;
      // Url used to download file/image
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('downloadUrl: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied')
        print('User does not have permission to upload to this reference');
    }
  }
}
