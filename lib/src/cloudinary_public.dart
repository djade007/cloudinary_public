import 'dart:convert';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloudinary_public/src/exceptions/cloudinary_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cloudinary_response.dart';
import '../cloudinary_public.dart';

/// The base class for this package
class CloudinaryPublic {
  /// Cloudinary api base url
  static const _baseUrl = 'https://api.cloudinary.com/v1_1';

  /// field name for the file
  static const _fieldName = 'file';

  /// To cache all the uploaded files in the current class instance
  Map<String?, CloudinaryResponse> _uploadedFiles = {};

  /// Cloud name from Cloudinary
  final String _cloudName;

  /// Upload preset from Cloudinary
  final String _uploadPreset;

  /// Defaults to false
  final bool cache;

  /// The http client to be used to upload files
  http.Client? client;

  CloudinaryPublic(
    this._cloudName,
    this._uploadPreset, {
    this.cache = false,
    this.client,
  }) {
    /// set default http client
    client ??= http.Client();
  }

  CloudinaryImage getImage(String publicId) {
    return CloudinaryImage.fromPublicId(_cloudName, publicId);
  }

  /// Upload multiple files together
  Future<List<CloudinaryResponse>> uploadFiles(
    List<CloudinaryFile> files, {
    String? uploadPreset,
  }) {
    return Future.wait(
      files.map(
        (file) => uploadFile(file, uploadPreset: uploadPreset),
      ),
    );
  }

  /// Upload the cloudinary file to using the public api
  /// Override the default upload preset (when [CloudinaryPublic] is instantiated) with this one (if specified).
  Future<CloudinaryResponse> uploadFile(
    CloudinaryFile file, {
    String? uploadPreset,
  }) async {
    if (cache) {
      assert(file.identifier != null, 'identifier is required for caching');

      if (_uploadedFiles.containsKey(file.identifier))
        return _uploadedFiles[file.identifier]!.enableCache();
    }

    final url = '$_baseUrl/$_cloudName/'
        '${describeEnum(file.resourceType).toLowerCase()}'
        '/upload';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    request.headers.addAll({
      'Accept': 'application/json',
    });

    final data = {
      'upload_preset': uploadPreset ?? _uploadPreset,
    };

    if (file.fromExternalUrl) {
      data[_fieldName] = file.url!;
    } else {
      request.files.add(
        await file.toMultipartFile(_fieldName),
      );
    }

    if (file.tags != null && file.tags!.isNotEmpty) {
      data['tags'] = file.tags!.join(',');
    }

    request.fields.addAll(data);

    final sendRequest = await client!.send(request);

    final res = await http.Response.fromStream(sendRequest);

    if (res.statusCode != 200) {
      throw CloudinaryException(res.body, res.statusCode, request: {
        'url': file.url,
        'path': file.filePath,
        'identifier': file.identifier,
      });
    }

    final cloudinaryResponse = CloudinaryResponse.fromMap(
      json.decode(res.body),
    );

    if (cache) {
      /// Temporary cache for this class instance
      _uploadedFiles[file.identifier] = cloudinaryResponse;
    }
    return cloudinaryResponse;
  }

  /// Upload the file using [uploadFile]
  Future<CloudinaryResponse> uploadFutureFile(
    Future<CloudinaryFile> file, {
    String? uploadPreset,
  }) async {
    return uploadFile(await file, uploadPreset: uploadPreset);
  }

  /// Upload multiple files using simultaneously [uploadFutureFile]
  Future<List<CloudinaryResponse>> multiUpload(
    List<Future<CloudinaryFile>> files, {
    String? uploadPreset,
  }) async {
    return Future.wait(
      files.map(
        (file) => uploadFutureFile(file, uploadPreset: uploadPreset),
      ),
    );
  }
}
