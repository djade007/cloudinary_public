# cloudinary_public

[![Build Status](https://travis-ci.org/djade007/cloudinary_public.svg?branch=master)](https://travis-ci.org/djade007/cloudinary_public) [![Coverage Status](https://coveralls.io/repos/github/djade007/cloudinary_public/badge.svg?branch=master)](https://coveralls.io/github/djade007/cloudinary_public?branch=master)

This package allows you to upload media files directly to [cloudinary](https://cloudinary.com/documentation/upload_images#unsigned_upload), without exposing your apiKey or secretKey.

## Getting started

Add the dependency `cloudinary_public: ^0.X.X` ([find recent version](https://pub.dev/packages/cloudinary_public#-installing-tab-)) to your project and start using it:
```dart
import 'package:cloudinary_public/cloudinary_public.dart';
```

### Using [Image Picker](https://pub.dev/packages/image_picker) Plugin
```
var image = await ImagePicker.pickImage(source: ImageSource.camera);

CloudinaryResponse response = await cloudinary.uploadFile(
    file: image,
    resourceType: CloudinaryResourceType.Image,
    filename: image.path, // optional if cache is false
);

print(response.secureUrl);
```

### Using [Multi Image Picker](https://https://pub.dev/packages/multi_image_picker) Plugin
```
final data = await asset.getByteData();

CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
    byteData: data,
    resourceType: CloudinaryResourceType.Image,
    filename: asset.identifier, // optional if cache is false
);

print(response.secureUrl);
```

