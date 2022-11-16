import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_test/flutter_test.dart';

import 'file_manager.dart';

const chunkSize10 = 1024 * 1024 * 10; // 10MB

void main() {
  late File tempFile;
  late File tempVideoFile;

  setUpAll(() {
    tempFile = getFile();
    tempVideoFile = getVideoFile();
  });

  tearDownAll(() {
    // delete generated video file
    deleteGeneratedVideoFile();
  });

  group('Cloudinary file size test', () {
    test('uploads an image file', () async {
      final file = CloudinaryFile.fromFile(tempFile.path);
      expect(file.fileSize, tempFile.lengthSync());
    });

    test('uploads an image from byte data', () async {
      final bytes = await getFutureByteData();
      final file = CloudinaryFile.fromByteData(bytes, identifier: 'test');
      expect(file.fileSize, tempFile.lengthSync());
    });

    test('uploads an image from bytes data', () async {
      final bytes = await getFutureByteData();
      final file = CloudinaryFile.fromBytesData(
        bytes.buffer.asUint8List(),
        identifier: 'test',
      );
      expect(file.fileSize, tempFile.lengthSync());
    });
  });

  group('cloudinary chunks test', () {
    test('chunks count and size', () async {
      // Getting file
      final file = tempVideoFile;
      CloudinaryFile videoFile = CloudinaryFile.fromFile(file.path);
      ByteData byteData = await getFutureVideoByteData();
      CloudinaryFile videoFileFromByteData = CloudinaryFile.fromByteData(
        byteData,
        identifier: 'video.mp4',
      );

      // Values from file
      int maxChunkSize = min(videoFile.fileSize, chunkSize10);
      int chunksCount = (videoFile.fileSize / maxChunkSize).ceil();

      var chunks = videoFile.createChunks(chunksCount, maxChunkSize);

      // count chunk size
      int chunkSize = 0;
      for (var element in chunks) {
        chunkSize += element.length;
      }

      // values from byte data
      int maxChunkSizeFromByteData =
          min(videoFileFromByteData.fileSize, chunkSize10);
      int chunksCountFromByteData =
          (videoFileFromByteData.fileSize / maxChunkSizeFromByteData).ceil();

      var chunksFromByteData = videoFileFromByteData.createChunks(
        chunksCountFromByteData,
        maxChunkSize,
      );

      int chunkSizeFromByteData = 0;
      for (var element in chunksFromByteData) {
        chunkSizeFromByteData += element.length;
      }

      // Tests
      expect(chunkSize, videoFile.fileSize);
      expect(chunks.length, chunksCount);
      expect(chunks.length, chunksFromByteData.length);
      expect(chunkSize, chunkSizeFromByteData);
      expect(chunkSizeFromByteData, videoFile.fileSize);
    });
  });
}
