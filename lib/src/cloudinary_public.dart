import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;


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
    return '$_cloudName/'
        '${describeEnum(type).toLowerCase()}'
        '/upload';
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

    Map<String, dynamic> data = generateFormData(file, uploadPreset: uploadPreset);

    if (file.fromExternalUrl) {
      data[_fieldName] = file.url!;
    } else {
      data[_fieldName] = await file.toMultipartFile(_fieldName);
    }

    var response = await _dio.post(
      _createUrl(file.resourceType),
      data: FormData.fromMap(data),
      onSendProgress: (int sent, int total) {
        print("sent: $sent, total: $total");
        if (onProgress != null) {
          onProgress(sent, total);
        }
      },
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
    if (file.filePath == null) return null;
    final tempFile = File(file.filePath!);
    final fileName = path.basename(file.filePath!);

    Response? finalResponse;

    int _fileSize = tempFile.lengthSync(); // 100MB
  
    int _maxChunkSize = min(_fileSize, chunkSize);

    int _chunksCount = (_fileSize / _maxChunkSize).ceil();

     Map<String, dynamic> data = generateFormData(file, uploadPreset: uploadPreset);

    try {
      for (int i = 0; i < _chunksCount; i++) {
        print('uploadVideoInChunks chunk $i of $_chunksCount');
        final start = i * _maxChunkSize;
        final end = min((i + 1) * _maxChunkSize, _fileSize);
        final chunkStream = tempFile.openRead(start, end);

        final formData = FormData.fromMap({
          "file": MultipartFile(chunkStream, end - start, filename: fileName),
          ...data
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
          onSendProgress: (int sent, int total) {
            print("sent: $sent, total: $total");
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
      print("CloudinaryService uploadVideo error: $e");
      throw e;
    }
    return cloudinaryResponse;
  }


  
  /// common function to generate form data
  /// Override the default upload preset (when [CloudinaryPublic] is instantiated) with this one (if specified).
  Map<String, dynamic> generateFormData(
    CloudinaryFile file, {
    String? uploadPreset,
  }) {
    final Map<String, dynamic> data = {
      'upload_preset': uploadPreset ?? _uploadPreset,
      if (file.publicId != null) 'public_id': file.publicId,
      if (file.folder != null) 'folder': file.folder,
      if (file.tags != null && file.tags!.isNotEmpty)
        'tags': file.tags!.join(','),
    };

    if (file.context != null && file.context!.isNotEmpty) {
      String context = '';

      file.context!.forEach((key, value) {
        context += '|$key=$value';
      });

      // remove the extra `|` at the beginning
      data['context'] = context.replaceFirst('|', '');
    }

    return data;
  }

}
