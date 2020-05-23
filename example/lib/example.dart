import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/services.dart';

main() async {
  // set cache as true if you don't want to make an upload call with files of the same filename
  // in such case if the filepath/identifier has already been uploaded before, you simply get the previously cached response.
  var cloudinary =
      CloudinaryPublic('CLOUD_NAME', 'UPLOAD_PRESET', cache: false);

  // Using a file. For example, gotten from: https://pub.dev/packages/image_picker
  File file = File('');
  CloudinaryResponse response = await cloudinary.uploadFile(
    CloudinaryFile.fromFile(file, resourceType: CloudinaryResourceType.Image),
  );

  print(response.secureUrl);

  // Using Byte Data. For example gotten from: https://pub.dev/packages/multi_image_picker
  // final byteData = await asset.getByteData();
  final byteData = ByteData(10);
  CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
    CloudinaryFile.fromByteData(
      byteData,
      resourceType: CloudinaryResourceType.Image,
      identifier: '_ASSET_IDENTIFIER_', // optional if cache is false
    ),
  );

  print(cloudinaryResponse.secureUrl);
}
