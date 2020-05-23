import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/services.dart';

main() async {
  // set cache as true if you don't want to make an upload call with files of the same filename
  // in such case if the filename has already been uploaded before, you simply get the previously cached response.
  var cloudinary =
      CloudinaryPublic('CLOUD_NAME', 'UPLOAD_PRESET', cache: false);

  // Using a file. For example, gotten from: https://pub.dev/packages/image_picker
  File file = File('');
  CloudinaryResponse response = await cloudinary.uploadFile(
    file: file,
    resourceType: CloudinaryResourceType.Image,
    filename: file.path, // optional if cache is false
  );
  print(response.secureUrl);

  // Using Byte Data. For example gotten from: https://pub.dev/packages/multi_image_picker
  // final data = await asset.getByteData();
  final data = ByteData(10);
  CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
    byteData: data,
    resourceType: CloudinaryResourceType.Image,
    filename: 'FILE_IDENTIFIER', // optional if cache is false
  );
  print(cloudinaryResponse.secureUrl);
}
