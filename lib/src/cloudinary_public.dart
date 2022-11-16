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
    ProgressCallback? onProgress,
  }) async {
    if (cache) {
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
    ProgressCallback? onProgress,
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
    ProgressCallback? onProgress,
    void Function(int index)? currentUploadIndex,
  }) async {
    return Future.wait(
      files.map(
        (file) {
          if (currentUploadIndex != null) {
            currentUploadIndex(files.indexOf(file));
          }
          return uploadFutureFile(
            file,
            uploadPreset: uploadPreset,
            onProgress: onProgress,
          );
        },
      ),
    );
  }

  /// Upload file in chunks
  /// default chunk size is 20 MB
  /// chunk size must be less than 20 MB and greater than 5 MB
  Future<CloudinaryResponse?> uploadFileInChunks(
    CloudinaryFile file, {
    String? uploadPreset,
    ProgressCallback? onProgress,
    int chunkSize = 20000000, // 20MB
  }) async {
    if (chunkSize > 20000000 || chunkSize < 5000000) {
      throw CloudinaryException(
        'Chunk size must be less than 20 MB and greater than 5 MB',
        0,
        request: {
          'url': file.url,
          'path': file.filePath,
          'public_id': file.identifier,
          'identifier': file.identifier,
        },
      );
    }
    CloudinaryResponse? cloudinaryResponse;

    Response? finalResponse;

    int _maxChunkSize = min(file.fileSize, chunkSize);

    int _chunksCount = (file.fileSize / _maxChunkSize).ceil();

    List<MultipartFile>? _chunks =
        file.createChunks(_chunksCount, _maxChunkSize);

    Map<String, dynamic> data =
        file.toFormData(uploadPreset: uploadPreset ?? _uploadPreset);
    try {
      for (int i = 0; i < _chunksCount; i++) {
        final start = i * _maxChunkSize;
        final end = min((i + 1) * _maxChunkSize, file.fileSize);

        final formData = FormData.fromMap({
          "file": _chunks[i],
          ...data,
        });

        finalResponse = await _dio.post(
          _createUrl(file.resourceType),
          data: formData,
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'multipart/form-data',
              "X-Unique-Upload-Id": file.identifier,
              'Content-Range': 'bytes $start-${end - 1}/${file.fileSize}',
            },
          ),
          onSendProgress: (sent, total) {
            // total progress
            final s = sent + i * _maxChunkSize;
            onProgress?.call(s, file.fileSize);
          },
        );
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
      throw e;
    }
    return cloudinaryResponse;
  }
}
