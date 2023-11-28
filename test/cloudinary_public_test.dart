import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'file_manager.dart';

const cloudName = 'test';
const uploadPreset = 'test';

class MockClient extends Mock implements Dio {}

void main() {
  late MockClient client;

  setUp(() {
    client = MockClient();
    when(
      () => client.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: any(named: 'data'),
        onSendProgress: any(named: 'onSendProgress'),
      ),
    ).thenAnswer(
      (_) async => Response(
        data: _sampleResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ),
    );

    when(
      () => client.post(
        'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
        data: any(named: 'data'),
        onSendProgress: any(named: 'onSendProgress'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response(
        data: _sampleResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ),
    );
  });

  tearDownAll(() => deleteGeneratedVideoFile());

  test('uploads an image from external url', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: true,
      dioClient: client,
    );

    final file = CloudinaryFile.fromUrl(
      'https://via.placeholder.com/400',
      resourceType: CloudinaryResourceType.Image,
    );

    final res = await cloudinary.uploadFile(file);
    expect(res, const TypeMatcher<CloudinaryResponse>());

    // test toString
    expect(res.toString(), res.toMap().toString());

    // test cache
    final secondUpload = await cloudinary.uploadFile(file);
    expect(secondUpload, const TypeMatcher<CloudinaryResponse>());
    expect(secondUpload.fromCache, true);
  });

  final tempFile = getFile();

  test('uploads an image file', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: true,
      dioClient: client,
    );

    final file = CloudinaryFile.fromFile(
      tempFile.path,
      resourceType: CloudinaryResourceType.Image,
      tags: ['trip'],
      context: {
        'alt': 'Image',
      },
    );
    final res = await cloudinary.uploadFile(file);
    expect(res, const TypeMatcher<CloudinaryResponse>());

    // test toString
    expect(res.toString(), res.toMap().toString());

    // test cache
    final secondUpload = await cloudinary.uploadFile(file);
    expect(secondUpload, const TypeMatcher<CloudinaryResponse>());
    expect(secondUpload.fromCache, true);
  });

  test('uploads an image file overriding the upload_preset', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: true,
      dioClient: client,
    );

    final file = CloudinaryFile.fromFile(
      tempFile.path,
      resourceType: CloudinaryResourceType.Image,
      tags: ['trip'],
    );
    final res = await cloudinary.uploadFile(file);
    expect(res, const TypeMatcher<CloudinaryResponse>());

    // test toString
    expect(res.toString(), res.toMap().toString());

    // test cache
    final secondUpload = await cloudinary.uploadFile(
      file,
      uploadPreset: 'another_preset',
    );
    expect(secondUpload, const TypeMatcher<CloudinaryResponse>());
    expect(secondUpload.fromCache, true);
  });

  test('upload multiple image files', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: true,
      dioClient: client,
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

    expect(uploadedFiles[0], const TypeMatcher<CloudinaryResponse>());

    expect(uploadedFiles[1], const TypeMatcher<CloudinaryResponse>());
  });

  test('upload multiple image byteData', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: true,
      dioClient: client,
    );

    final files = <Future<CloudinaryFile>>[];
    final file = CloudinaryFile.fromFutureByteData(
      getFutureByteData(),
      resourceType: CloudinaryResourceType.Image,
      identifier: 'image.jpg',
    );

    files.add(file);
    files.add(file);

    final uploadedFiles = await cloudinary.multiUpload(files);

    expect(uploadedFiles.length, 2);

    expect(uploadedFiles[0], const TypeMatcher<CloudinaryResponse>());

    expect(uploadedFiles[1], const TypeMatcher<CloudinaryResponse>());
  });

  test('Test transformation', () {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: true,
      dioClient: client,
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
      url,
    );
  });

  test('thumbnail shortcut', () {
    final cloudinary = CloudinaryPublic(
      'demo',
      'present',
      cache: true,
    );

    final image = cloudinary.getImage('cloudinary_icon');
    expect(
        image.thumbnail().toString(),
        'https://res.cloudinary.com/demo/image/upload/c_thumb,g_face,'
        'h_200,w_200/cloudinary_icon');
  });

  test('Upload file in Chunks', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: true,
      dioClient: client,
    );
    final videoFile = getVideoFile();

    final file = CloudinaryFile.fromFile(
      videoFile.path,
      resourceType: CloudinaryResourceType.Video,
      tags: ['trip'],
    );
    final res = await cloudinary.uploadFileInChunks(file);
    expect(res, const TypeMatcher<CloudinaryResponse>());
  });

  test('Upload file bytes in chunks', () async {
    final cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: true,
      dioClient: client,
    );
    final videoBytes = getFutureVideoByteData();

    final file = await CloudinaryFile.fromFutureByteData(
      videoBytes,
      resourceType: CloudinaryResourceType.Video,
      identifier: 'video.mp4',
    );
    final res = await cloudinary.uploadFileInChunks(file);
    expect(res, const TypeMatcher<CloudinaryResponse>());
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
};
