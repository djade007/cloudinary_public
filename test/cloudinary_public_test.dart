import 'dart:convert';
import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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
  // mock http client
  final client = MockClient(
    (request) async => http.Response(
      jsonEncode(_sampleResponse),
      200,
    ),
  );

  test('uploads an image from external url', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
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
      cache: true,
    );

    final file = CloudinaryFile.fromFile(tempFile.path,
        resourceType: CloudinaryResourceType.Image,
        tags: [
          'trip'
        ],
        context: {
          'alt': 'Image',
        });
    final res = await cloudinary.uploadFile(file);
    expect(res, TypeMatcher<CloudinaryResponse>());

    // test toString
    expect(res.toString(), res.toMap().toString());

    // test cache
    final secondUpload = await cloudinary.uploadFile(file);
    expect(secondUpload, TypeMatcher<CloudinaryResponse>());
    expect(secondUpload.fromCache, true);
  });

  test('uploads an image file overriding the upload_preset', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: true,
    );

    final file = CloudinaryFile.fromFile(tempFile.path,
        resourceType: CloudinaryResourceType.Image, tags: ['trip']);
    final res = await cloudinary.uploadFile(file);
    expect(res, TypeMatcher<CloudinaryResponse>());

    // test toString
    expect(res.toString(), res.toMap().toString());

    // test cache
    final secondUpload = await cloudinary.uploadFile(
      file,
      uploadPreset: 'another_preset',
    );
    expect(secondUpload, TypeMatcher<CloudinaryResponse>());
    expect(secondUpload.fromCache, true);
  });

  test('upload multiple image files', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: true,
    );

    final files = <CloudinaryFile>[];
    final file = CloudinaryFile.fromFile(
      tempFile.path,
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
      cache: true,
    );

    final files = <Future<CloudinaryFile>>[];
    final file = CloudinaryFile.fromFutureByteData(
      Future.value(ByteData(8)),
      resourceType: CloudinaryResourceType.Image,
      identifier: 'image.jpg',
    );

    files.add(file);
    files.add(file);

    final uploadedFiles = await cloudinary.multiUpload(files);

    expect(uploadedFiles.length, 2);

    expect(uploadedFiles[0], TypeMatcher<CloudinaryResponse>());

    expect(uploadedFiles[1], TypeMatcher<CloudinaryResponse>());
  });

  test('Test transformation', () {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: true,
    );

    final image = CloudinaryImage(
      'https://res.cloudinary.com/demo/image/upload/front_face.png',
    );

    final url = image
        .transform()
        .width(150)
        .height(150)
        .gravity('face')
        .crop('thumb')
        .chain()
        .radius(20)
        .chain()
        .effect('sepia')
        .chain()
        .overlay(cloudinary.getImage('cloudinary_icon'))
        .gravity('south_east')
        .x(5)
        .y(5)
        .width(50)
        .opacity(60)
        .effect('brightness:200')
        .chain()
        .angle(10)
        .generate();

    expect(
        'https://res.cloudinary.com/demo/image/upload/c_thumb,g_face,h_150,'
        'w_150/r_20/e_sepia/e_brightness:200,g_south_east,l_cloudinary_icon,'
        'o_60,w_50,x_5,y_5/a_10/front_face.png',
        url);
  });

  test('thumbnail shortcut', () {
    final cloudinary = CloudinaryPublic(
      "demo",
      "present",
      cache: true,
    );

    final image = cloudinary.getImage('cloudinary_icon');
    expect(
        image.thumbnail().toString(),
        'https://res.cloudinary.com/demo/image/upload/c_thumb,g_face,'
        'h_200,w_200/cloudinary_icon');
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
  'original_filename': '001',
  'context': {
    'custom': {
      'alt': 'image',
      'caption': 'Example image',
    }
  }
};
