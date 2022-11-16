import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cloudinary_file_test.dart';

const cloudName = 'test';
const uploadPreset = 'test';

void main() {
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
