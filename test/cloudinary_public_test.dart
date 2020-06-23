import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements Dio {}

File getFile() {
  File file = File('../test/icon.png');
  try {
    file.lengthSync();
  } catch (exception) {
    file = File('test/icon.png');
  }
  return file;
}

const cloudName = 'name';
const uploadPreset = 'preset';

void main() {
  final client = MockClient();

  // Use Mockito to return a successful response when it calls the
  // provided dio.post
  when(client.post(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    data: anyNamed('data'),
  )).thenAnswer(
    (_) async => Response(
      data: _sampleResponse,
      statusCode: 200,
    ),
  );

  test('uploads an image from external url', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      dioClient: client,
      cache: true,
    );

    final file = CloudinaryFile.fromUrl(
      'https://via.placeholder.com/400',
      resourceType: CloudinaryResourceType.Image,
    );

    final res = await cloudinary.uploadFile(file);
    expect(res, TypeMatcher<CloudinaryResponse>());

    // test toString
    expect(res.toString(), res.toMap().toString());

    // test cache
    final secondUpload = await cloudinary.uploadFile(file);
    expect(secondUpload, TypeMatcher<CloudinaryResponse>());
    expect(secondUpload.fromCache, true);
  });

  final tempFile = getFile();

  test('uploads an image file', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      dioClient: client,
      cache: true,
    );

    final file = CloudinaryFile.fromFile(
      tempFile,
      resourceType: CloudinaryResourceType.Image,
    );
    final res = await cloudinary.uploadFile(file);
    expect(res, TypeMatcher<CloudinaryResponse>());

    // test toString
    expect(res.toString(), res.toMap().toString());

    // test cache
    final secondUpload = await cloudinary.uploadFile(file);
    expect(secondUpload, TypeMatcher<CloudinaryResponse>());
    expect(secondUpload.fromCache, true);
  });

  test('upload multiple image files', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      dioClient: client,
      cache: true,
    );

    final files = <CloudinaryFile>[];
    final file = CloudinaryFile.fromFile(
      tempFile,
      resourceType: CloudinaryResourceType.Image,
    );
    files.add(file);
    files.add(file);
    final uploadedFiles = await cloudinary.uploadFiles(files);

    expect(uploadedFiles.length, 2);

    expect(uploadedFiles[0], TypeMatcher<CloudinaryResponse>());

    expect(uploadedFiles[1], TypeMatcher<CloudinaryResponse>());
  });

  test('upload multiple image byteData', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      dioClient: client,
      cache: true,
    );

    final files = <Future<CloudinaryFile>>[];
    final file = CloudinaryFile.fromFutureByteData(Future.value(ByteData(8)),
        resourceType: CloudinaryResourceType.Image, identifier: 'image.jpg');

    files.add(file);
    files.add(file);

    final uploadedFiles = await cloudinary.multiUpload(files);

    expect(uploadedFiles.length, 2);

    expect(uploadedFiles[0], TypeMatcher<CloudinaryResponse>());

    expect(uploadedFiles[1], TypeMatcher<CloudinaryResponse>());
  });
}

const _sampleResponse = {
  'asset_id': '82345c4e10d4c019658b3334cde497ed9',
  'public_id': 'psryios0nkgpf1h4a3h',
  'version': '1590212116',
  'version_id': 'd5c175f90d3daf799cda96ead698368ea',
  'signature': '08a8183b499d1cd3aa46ea54ab278c14b8cfbba',
  'width': '1668',
  'height': '2500',
  'format': 'jpg',
  'resource_type': 'image',
  'created_at': '2020-05-23T05:35:16Z',
  'tags': [],
  'bytes': '3331383',
  'type': 'upload',
  'etag': '787996e313bcdd299d090b20389tta8d',
  'placeholder': 'false',
  'url':
      'http://res.cloudinary.com/$cloudName/image/upload/v1590212116/psryios0nkgpf1h4um3h.jpg',
  'secure_url':
      'https://res.cloudinary.com/$cloudName/image/upload/v1590212116/psryios0nkgpf1h4um3h.jpg',
  'original_filename': '001'
};
