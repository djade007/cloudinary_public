import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The recognised file class to be used for this package
class CloudinaryFile {
  /// The [ByteData] file to be uploaded
  final ByteData byteData;

  /// The path of the [File] to be uploaded
  final String filePath;

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

  /// File tags
  final List<String> tags;

  /// [CloudinaryFile] instance
  const CloudinaryFile(
      {this.byteData,
      this.filePath,
      this.identifier,
      this.url,
      @required this.resourceType,
      this.tags})
      : assert(
            (byteData == null && filePath != null) ||
                (byteData != null && filePath == null) ||
                url != null,
            'Only one between byteData or file must be provided');

  /// Instantiate [CloudinaryFile] from future [ByteData]
  static Future<CloudinaryFile> fromFutureByteData(Future<ByteData> byteData,
          {String identifier,
          CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
          List<String> tags}) async =>
      CloudinaryFile.fromByteData(
        await byteData,
        identifier: identifier,
        resourceType: resourceType,
        tags: tags,
      );

  /// Instantiate [CloudinaryFile] from [ByteData]
  factory CloudinaryFile.fromByteData(ByteData byteData,
          {String identifier,
          CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
          List<String> tags}) =>
      CloudinaryFile(
        byteData: byteData,
        identifier: identifier,
        resourceType: resourceType,
        tags: tags,
      );

  /// Instantiate [CloudinaryFile] from [File] path
  factory CloudinaryFile.fromFile(String path,
          {String identifier,
          CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
          List<String> tags}) =>
      CloudinaryFile(
        filePath: path,
        identifier: identifier ??= path.split('/').last,
        resourceType: resourceType,
        tags: tags,
      );

  /// Instantiate [CloudinaryFile] from an external url
  factory CloudinaryFile.fromUrl(String url,
          {CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
          List<String> tags}) =>
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
    return MultipartFile.fromFileSync(
      filePath,
      filename: identifier,
    );
  }
}
