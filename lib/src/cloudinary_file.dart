import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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

  /// Determine if initialized from [CloudinaryFile.fromUrl]
  bool get fromExternalUrl => url != null;

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
  Future<http.MultipartFile> toMultipartFile(
      [String fieldName = 'file']) async {
    assert(
      !fromExternalUrl,
      'toMultipartFile() not available when uploading from external urls',
    );

    if (byteData != null) {
      return http.MultipartFile.fromBytes(
        fieldName,
        byteData.buffer.asUint8List(),
        filename: identifier,
      );
    }

    if (kIsWeb) {
      final bytes = await http.readBytes(Uri.parse(filePath));
      return http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: identifier,
      );
    }

    return http.MultipartFile.fromPath(
      fieldName,
      filePath,
      filename: identifier,
    );
  }
}
