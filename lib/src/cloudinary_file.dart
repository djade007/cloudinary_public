import 'dart:io';
import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// The recognised file class to be used for this package
class CloudinaryFile {
  /// The [ByteData] file to be uploaded
  final ByteData? byteData;

  /// The bytes data to be uploaded
  final List<int>? bytesData;

  /// The path of the [File] to be uploaded
  final String? filePath;

  /// The file public id which will be used to name the file
  final String? publicId;

  /// The file name/path
  final String? identifier;

  /// An optional folder name where the uploaded asset will be stored.
  /// The public ID will contain the full path of the uploaded asset,
  /// including the folder name.
  final String? folder;

  /// External url
  final String? url;

  /// The cloudinary resource type to be uploaded
  /// see [CloudinaryResourceType.Auto] - default,
  /// [CloudinaryResourceType.Image],
  /// [CloudinaryResourceType.Video],
  /// [CloudinaryResourceType.Raw],
  final CloudinaryResourceType resourceType;

  /// File tags
  final List<String>? tags;

  /// A pipe-separated list of the key-value pairs of contextual metadata to
  /// attach to an uploaded asset.
  ///
  /// Eg: {'alt': 'My image', 'caption': 'Profile image'}
  final Map<String, dynamic>? context;

  /// Determine if initialized from [CloudinaryFile.fromUrl]
  bool get fromExternalUrl => url != null;

  /// [CloudinaryFile] instance
  const CloudinaryFile._({
    this.resourceType: CloudinaryResourceType.Auto,
    this.byteData,
    this.bytesData,
    this.filePath,
    this.publicId,
    this.identifier,
    this.url,
    this.tags,
    this.folder,
    this.context,
  });

  /// Instantiate [CloudinaryFile] from future [ByteData]
  static Future<CloudinaryFile> fromFutureByteData(Future<ByteData> byteData,
          {String? publicId,
          String? identifier,
          CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
          List<String>? tags}) async =>
      CloudinaryFile.fromByteData(
        await byteData,
        publicId: publicId,
        identifier: identifier,
        resourceType: resourceType,
        tags: tags,
      );

  /// Instantiate [CloudinaryFile] from [ByteData]
  factory CloudinaryFile.fromByteData(
    ByteData byteData, {
    String? publicId,
    String? identifier,
    CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
    List<String>? tags,
    String? folder,
    Map<String, dynamic>? context,
  }) {
    return CloudinaryFile._(
      byteData: byteData,
      publicId: publicId,
      identifier: identifier,
      resourceType: resourceType,
      tags: tags,
      folder: folder,
      context: context,
    );
  }

  /// Instantiate [CloudinaryFile] from [ByteData]
  factory CloudinaryFile.fromBytesData(
    List<int> bytesData, {
    String? publicId,
    String? identifier,
    CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
    List<String>? tags,
    String? folder,
    Map<String, dynamic>? context,
  }) {
    return CloudinaryFile._(
      bytesData: bytesData,
      publicId: publicId,
      identifier: identifier,
      resourceType: resourceType,
      tags: tags,
      folder: folder,
      context: context,
    );
  }

  /// Instantiate [CloudinaryFile] from [File] path
  factory CloudinaryFile.fromFile(
    String path, {
    String? publicId,
    String? identifier,
    CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
    List<String>? tags,
    String? folder,
    Map<String, dynamic>? context,
  }) {
    return CloudinaryFile._(
      filePath: path,
      publicId: publicId,
      identifier: identifier ??= path.split('/').last,
      resourceType: resourceType,
      tags: tags,
      folder: folder,
      context: context,
    );
  }

  /// Instantiate [CloudinaryFile] from an external url
  factory CloudinaryFile.fromUrl(
    String url, {
    CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
    List<String>? tags,
    String? folder,
    Map<String, dynamic>? context,
  }) {
    return CloudinaryFile._(
      url: url,
      identifier: url,
      resourceType: resourceType,
      folder: folder,
      context: context,
    );
  }

  /// Convert [CloudinaryFile] to [MultipartFile]
  Future<MultipartFile> toMultipartFile([String fieldName = 'file']) async {
    assert(
      !fromExternalUrl,
      'toMultipartFile() not available when uploading from external urls',
    );

    if (byteData != null) {
      return MultipartFile.fromBytes(
        byteData?.buffer.asUint8List()?? [],
        filename: identifier,
      );
    }

    if (bytesData != null) {
      return MultipartFile.fromBytes(
        bytesData!,
        filename: identifier,
      );
    }

    if (kIsWeb) {
      final bytes = await http.readBytes(Uri.parse(filePath!));
      return MultipartFile.fromBytes(
        bytes.buffer.asUint8List(),
        filename: identifier,
      );
    }

    return MultipartFile.fromFile(
      filePath!,
      filename: identifier,
    );
  }

  /// Convert to multipart with chunked upload
  MultipartFile toMultipartFileChunked(
    int start,
    int end,
  ) {
    assert(
      !fromExternalUrl,
      'toMultipartFileChunked() not available when uploading from external urls',
    );
    Stream<List<int>> chunkStream;
    if (byteData != null) {
      chunkStream = Stream.fromIterable(
        byteData!.buffer.asInt8List(start, end - start).map((e) => [e]),
      );
    } else if (bytesData != null) {
      chunkStream = Stream.fromIterable(
        bytesData!.map((e) => [e]),
      );
    }
    if (kIsWeb) {
      chunkStream = http.readBytes(Uri.parse(filePath!)).asStream();
    } else {
      chunkStream = File(filePath!).openRead(start, end);
    }

    return MultipartFile(
      chunkStream,
      end - start,
      filename: identifier,
    );
  }

  /// common function to generate form data
  /// Override the default upload preset (when [CloudinaryPublic] is instantiated) with this one (if specified).
  Map<String, dynamic> toFormData({
    required String uploadPreset,
  }) {
    final Map<String, dynamic> data = {
      'upload_preset': uploadPreset,
      if (publicId != null) 'public_id': publicId,
      if (folder != null) 'folder': folder,
      if (tags != null && tags!.isNotEmpty) 'tags': tags!.join(','),
    };

    if (context != null && context!.isNotEmpty) {
      String context = '';

      this.context!.forEach((key, value) {
        context += '|$key=$value';
      });

      // remove the extra `|` at the beginning
      data['context'] = context.replaceFirst('|', '');
    }

    return data;
  }
}
