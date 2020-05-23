library cloudinary_public;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CloudinaryPublic {
  static const _baseUrl = 'https://api.cloudinary.com/v1_1';
  Map<String, CloudinaryResponse> _uploadedFiles = {};
  final String _cloudName;
  final String _uploadPreset;
  final bool cache;
  Dio dioClient;

  CloudinaryPublic(this._cloudName, this._uploadPreset,
      {this.cache = false, this.dioClient}) {
    // set default dio client
    dioClient ??= Dio();
  }

  Future<CloudinaryResponse> uploadFile({
    ByteData byteData,
    File file,
    CloudinaryResourceType resourceType: CloudinaryResourceType.Auto,
    String filename,
  }) async {
    assert(
        (byteData == null && file != null) ||
            (byteData != null && file == null),
        'only one between byteData or file must be provided');

    if (cache) {
      assert(filename != null, 'filename is required for caching');
      if (_uploadedFiles.containsKey(filename)) return _uploadedFiles[filename];
    }

    FormData formData = FormData.fromMap({
      'file': byteData != null
          ? MultipartFile.fromBytes(
              byteData.buffer.asUint8List(),
              filename: filename,
            )
          : MultipartFile.fromFile(file.path, filename: filename),
      'upload_preset': _uploadPreset
    });

    // throws DioError
    final res = await dioClient.post(
      '$_baseUrl/$_cloudName/${describeEnum(resourceType).toLowerCase()}/upload',
      data: formData,
    );
    final cloudinaryResponse = CloudinaryResponse.fromMap(res.data);

    if (cache) { // temporary cache for this class instance
      _uploadedFiles[filename] = cloudinaryResponse;
    }
    return cloudinaryResponse;
  }
}

enum CloudinaryResourceType { Image, Raw, Video, Auto }

class CloudinaryResponse {
  final String assetId;
  final String publicId;
  final DateTime createdAt;
  final String url;
  final String secureUrl;
  final String originalFilename;

  CloudinaryResponse({
    this.assetId,
    this.publicId,
    this.createdAt,
    this.url,
    this.secureUrl,
    this.originalFilename,
  });

  factory CloudinaryResponse.fromMap(Map<String, dynamic> data) {
    return CloudinaryResponse(
      assetId: data['asset_id'],
      publicId: data['public_id'],
      createdAt: DateTime.parse(data['created_at']),
      url: data['url'],
      secureUrl: data['secure_url'],
      originalFilename: data['original_filename'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'asset_id': assetId,
      'public_id': publicId,
      'created_at': createdAt.toString(),
      'url': url,
      'secure_url': secureUrl,
      'original_filename': originalFilename
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
