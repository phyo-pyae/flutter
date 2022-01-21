import 'package:flutter/cupertino.dart';

class ImageModel {
  ImageModel({@required this.url});
  final String url;

  //use when we read data like this
  factory ImageModel.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String url = data['url'];

    return ImageModel(
      url: documentId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
    };
  }
}
