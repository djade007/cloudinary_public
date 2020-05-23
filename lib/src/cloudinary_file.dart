import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CloudinaryFile {
  final ByteData byteData;
  final File file;
  final String identifier;
  final CloudinaryResourceType resourceType;

  const CloudinaryFile({
    this.byteData,
    this.file,
    this.identifier,
    @required this.resourceType,
  }) : assert(
            (byteData == null && file != null) ||
                (byteData != null && file == null),
            'Only one between byteData or file must be provided');

  factory CloudinaryFile.fromByteData(
    ByteData byteData, {
    String identifier,
    CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
  }) =>
      CloudinaryFile(
          byteData: byteData,
          identifier: identifier,
          resourceType: resourceType);

  factory CloudinaryFile.fromFile(
    File file, {
    String identifier,
    CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
  }) =>
      CloudinaryFile(
        file: file,
        identifier: identifier ??= file.path,
        resourceType: resourceType,
      );

  Future<MultipartFile> toMultipartFile() async {
    if (byteData != null) {
      return MultipartFile.fromBytes(
        byteData.buffer.asUint8List(),
        filename: identifier,
      );
    }
    return MultipartFile.fromFile(file.path, filename: identifier);
  }
}
