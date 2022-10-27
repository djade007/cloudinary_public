import 'dart:io';
import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  final tempFile = getFile();
  group("Cloudinary file size test", () {
    test('uploads an image file', () async {
      final file = CloudinaryFile.fromFile(tempFile.path);
      expect(file.fileSize, tempFile.lengthSync());
    });

    test('uploads an image from byte data', () async {
      final bytes = await getFutureByteData();
      final file = CloudinaryFile.fromByteData(bytes);
      expect(file.fileSize, tempFile.lengthSync());
    });

    test('uploads an image from bytes data', () async {
      final bytes = await getFutureByteData();
      final file = CloudinaryFile.fromBytesData(bytes.buffer.asUint8List());
      expect(file.fileSize, tempFile.lengthSync());
    });
  });
}
