import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import './cloudinary_response.dart';

class CloudinaryPublic {
  static const _baseUrl = 'https://api.cloudinary.com/v1_1';
  Map<String, CloudinaryResponse> _uploadedFiles = {};
  final String _cloudName;
  final String _uploadPreset;
  final bool cache;
  Dio dioClient;

  CloudinaryPublic(
    this._cloudName,
    this._uploadPreset, {
    this.cache = false,
    this.dioClient,
  }) {
    // set default dio client
    dioClient ??= Dio();
  }

  Future<List<CloudinaryResponse>> uploadFiles(
      List<CloudinaryFile> files) async {
    return await Future.wait(files.map((file) => uploadFile(file)));
  }

  Future<CloudinaryResponse> uploadFile(CloudinaryFile file) async {
    if (cache) {
      assert(file.identifier != null, 'identifier is required for caching');

      if (_uploadedFiles.containsKey(file.identifier))
        return _uploadedFiles[file.identifier];
    }

    FormData formData = FormData.fromMap({
      'file': await file.toMultipartFile(),
      'upload_preset': _uploadPreset,
    });

    // throws DioError
    final res = await dioClient.post(
      '$_baseUrl/$_cloudName/${describeEnum(file.resourceType).toLowerCase()}/upload',
      data: formData,
    );

    final cloudinaryResponse = CloudinaryResponse.fromMap(res.data);

    if (cache) {
      // temporary cache for this class instance
      _uploadedFiles[file.identifier] = cloudinaryResponse;
    }
    return cloudinaryResponse;
  }
}
