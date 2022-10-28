import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_test/flutter_test.dart';

const chunkSize = 1024 * 1024 * 10; // 10MB

File getFile() {
  File file = File('../test/icon.png');
  try {
    file.lengthSync();
  } catch (exception) {
    file = File('test/icon.png');
  }
  return file;
}

Future<ByteData> getFutureByteData() async {
  final tempFile = getFile();
  Uint8List uIntBytes = tempFile.readAsBytesSync();
  ByteData bytes = (ByteData.view(uIntBytes.buffer));
  return Future.value(bytes);
}

// To test video add sample video to test folder
File getVideoFile() {
  File file = File('../test/video.mp4');
  try {
    file.lengthSync();
  } catch (exception) {
    file = File('test/video.mp4');
  }
  return file;
}

Future<ByteData> getFutureVideoByteData() {
  final tempFile = getVideoFile();
  Uint8List uIntBytes = tempFile.readAsBytesSync();
  ByteData bytes = (ByteData.view(uIntBytes.buffer));
  return Future.value(bytes);
}

void main() {
  final tempFile = getFile();
  group("Cloudinary file size test", () {
    test('uploads an image file', () async {
      final file = CloudinaryFile.fromFile(tempFile.path);
      expect(file.fileSize, tempFile.lengthSync());
    });

    test('uploads an image from byte data', () async {
      final bytes = await getFutureByteData();
      final file = CloudinaryFile.fromByteData(bytes, identifier: "test");
      expect(file.fileSize, tempFile.lengthSync());
    });

    test('uploads an image from bytes data', () async {
      final bytes = await getFutureByteData();
      final file = CloudinaryFile.fromBytesData(
        bytes.buffer.asUint8List(),
        identifier: "test",
      );
      expect(file.fileSize, tempFile.lengthSync());
    });
  });

  group("cloudinary chunks test", () {
    test("chunks count and size", () async {
      // Getting file
      File file = getVideoFile();
      CloudinaryFile videoFile = CloudinaryFile.fromFile(file.path);
      ByteData byteData = await getFutureVideoByteData();
      CloudinaryFile videoFileFromByteData = CloudinaryFile.fromByteData(
        byteData,
        identifier: "video.mp4",
      );

      // Values from file
      int _maxChunkSize = min(videoFile.fileSize, chunkSize);
      int _chunksCount = (videoFile.fileSize / _maxChunkSize).ceil();

      var chunks = videoFile.createChunks(_chunksCount, _maxChunkSize);

      // count chunk size
      int _chunkSize = 0;
      chunks.forEach((element) {
        _chunkSize += element.length;
      });

      // values from byte data
      int _maxChunkSizeFromByteData =
          min(videoFileFromByteData.fileSize, chunkSize);
      int _chunksCountFromByteData =
          (videoFileFromByteData.fileSize / _maxChunkSizeFromByteData).ceil();

      var chunksFromByteData = videoFileFromByteData.createChunks(
          _chunksCountFromByteData, _maxChunkSize);

      int _chunkSizeFromByteData = 0;
      chunksFromByteData.forEach((element) {
        _chunkSizeFromByteData += element.length;
      });

      // Tests
      expect(_chunkSize, videoFile.fileSize);
      expect(chunks.length, _chunksCount);
      expect(chunks.length, chunksFromByteData.length);
      expect(_chunkSize, _chunkSizeFromByteData);
      expect(_chunkSizeFromByteData, videoFile.fileSize);
    });
  });
}
