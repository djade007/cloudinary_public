import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The recognised file class to be used for this package
class CloudinaryFile {
  /// The [ByteData] file to be uploaded
  final ByteData byteData;

  /// The [File] to be uploaded
  final File file;

  /// The file name/path
  final String identifier;

  /// External url
  final String url;

  /// The cloudinary resource type to be uploaded
  /// see [CloudinaryResourceType.Auto] - default,
  /// [CloudinaryResourceType.Image],
  /// [CloudinaryResourceType.Video],
  /// [CloudinaryResourceType.Raw],
  final CloudinaryResourceType resourceType;

  /// [CloudinaryFile] instance
  const CloudinaryFile({
    this.byteData,
    this.file,
    this.identifier,
    this.url,
    @required this.resourceType,
  }) : assert(
            (byteData == null && file != null) ||
                (byteData != null && file == null) ||
                url != null,
            'Only one between byteData or file must be provided');

  /// Instantiate [CloudinaryFile] from future [ByteData]
  static Future<CloudinaryFile> fromFutureByteData(
    Future<ByteData> byteData, {
    String identifier,
    CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
  }) async =>
      CloudinaryFile.fromByteData(
        await byteData,
        identifier: identifier,
        resourceType: resourceType,
      );

  /// Instantiate [CloudinaryFile] from [ByteData]
  factory CloudinaryFile.fromByteData(
    ByteData byteData, {
    String identifier,
    CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
  }) =>
      CloudinaryFile(
          byteData: byteData,
          identifier: identifier,
          resourceType: resourceType);

  /// Instantiate [CloudinaryFile] from [File]
  factory CloudinaryFile.fromFile(
    File file, {
    String identifier,
    CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
  }) =>
      CloudinaryFile(
        file: file,
        identifier: identifier ??= file.path.split('/').last,
        resourceType: resourceType,
      );

  /// Instantiate [CloudinaryFile] from an external url
  factory CloudinaryFile.fromUrl(
    String url, {
    CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
  }) =>
      CloudinaryFile(
        url: url,
        identifier: url,
        resourceType: resourceType,
      );

  /// Convert [CloudinaryFile] to [MultipartFile]
  MultipartFile toMultipartFile() {
    if (url != null) return null;

    if (byteData != null) {
      return MultipartFile.fromBytes(
        byteData.buffer.asUint8List(),
        filename: identifier,
      );
    }
    return MultipartFile.fromFileSync(file.path, filename: identifier);
  }
}
