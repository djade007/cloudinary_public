import 'dart:async';
import 'dart:math';
// ignore: unused_import
import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// The base class for this package
class CloudinaryPublic {
  /// Cloudinary api base url
  static const _baseUrl = 'https://api.cloudinary.com/v1_1';

  /// field name for the file
  static const _fieldName = 'file';

  /// To cache all the uploaded files in the current class instance
  Map<String?, CloudinaryResponse> _uploadedFiles = {};

  static Dio _dio = Dio();

  /// Cloud name from Cloudinary
  final String _cloudName;

  /// Upload preset from Cloudinary
  final String _uploadPreset;

  /// Defaults to false
  final bool cache;

  CloudinaryPublic(
    this._cloudName,
    this._uploadPreset, {
    this.cache = false,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'multipart/form-data'
        },
      ),
    );
  }

  String _createUrl(CloudinaryResourceType type) {
    var url = '$_baseUrl/$_cloudName/'
        '${describeEnum(type).toLowerCase()}'
        '/upload';
    print(url);
    return url;
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
    Function(int, int)? onProgress,
  }) async {
    if (cache) {
      assert(file.identifier != null, 'identifier is required for caching');

      if (_uploadedFiles.containsKey(file.identifier))
        return _uploadedFiles[file.identifier]!.enableCache();
    }

    Map<String, dynamic> data =
        file.toFormData(uploadPreset: uploadPreset ?? _uploadPreset);

    if (file.fromExternalUrl) {
      data[_fieldName] = file.url!;
    } else {
      data[_fieldName] = await file.toMultipartFile(_fieldName);
    }

    var response = await _dio.post(
      _createUrl(file.resourceType),
      data: FormData.fromMap(data),
      onSendProgress: onProgress,
    );

    if (response.statusCode != 200) {
      throw CloudinaryException(
        response.data,
        response.statusCode ?? 0,
        request: {
          'url': file.url,
          'path': file.filePath,
          'public_id': file.identifier,
          'identifier': file.identifier,
        },
      );
    }

    final cloudinaryResponse = CloudinaryResponse.fromMap(
      response.data,
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
    Function(int, int)? onProgress,
  }) async {
    return uploadFile(
      await file,
      uploadPreset: uploadPreset,
      onProgress: onProgress,
    );
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

  /// Upload file in chunks
  /// default chunk size is 10 MB
  Future<CloudinaryResponse?> uploadFileInChunks(
    CloudinaryFile file, {
    String? uploadPreset,
    Function(int, int)? onProgress,
    int chunkSize = 10000000, // 10MB
  }) async {
    CloudinaryResponse? cloudinaryResponse;

    print("uploadFileInChunks: fileSize ${file.fileSize}");

    Response? finalResponse;

    int _fileSize = file.fileSize; // 100MB

    int _maxChunkSize = min(_fileSize, chunkSize);

    int _chunksCount = (_fileSize / _maxChunkSize).ceil();

    Map<String, dynamic> data =
        file.toFormData(uploadPreset: uploadPreset ?? _uploadPreset);
    try {
      for (int i = 0; i < _chunksCount; i++) {
        print('uploadVideoInChunks chunk $i of $_chunksCount');
        final start = i * _maxChunkSize;
        final end = min((i + 1) * _maxChunkSize, _fileSize);

        final formData = FormData.fromMap({
          "file": file.toMultipartFileChunked(start, end),
          ...data,
        });

        finalResponse = await _dio.post(
          _createUrl(file.resourceType),
          data: formData,
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'multipart/form-data',
              "X-Unique-Upload-Id": file.filePath,
              'Content-Range': 'bytes $start-${end - 1}/$_fileSize',
            },
          ),
          onSendProgress: (sent, total) {
            // total progress
            final s = sent + i * _maxChunkSize;
            onProgress?.call(s, _fileSize);
          },
        );
        print('uploadVideoInChunks finalResponse $i $finalResponse');
      }

      if (finalResponse?.statusCode != 200 || finalResponse == null) {
        throw CloudinaryException(
          finalResponse?.data,
          finalResponse?.statusCode ?? 0,
          request: {
            'url': file.url,
            'path': file.filePath,
            'public_id': file.identifier,
            'identifier': file.identifier,
          },
        );
      }

      cloudinaryResponse = CloudinaryResponse.fromMap(
        finalResponse.data,
      );
    } catch (e) {
      print("CloudinaryService uploadFileInChunks error: $e");
      throw e;
    }
    return cloudinaryResponse;
  }
}
