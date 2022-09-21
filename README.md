# cloudinary_public

[![Build Status](https://travis-ci.org/djade007/cloudinary_public.svg?branch=master)](https://travis-ci.org/djade007/cloudinary_public) [![Coverage Status](https://coveralls.io/repos/github/djade007/cloudinary_public/badge.svg?branch=master)](https://coveralls.io/github/djade007/cloudinary_public?branch=master)

This package allows you to upload media files directly
to [cloudinary](https://cloudinary.com/documentation/upload_images#unsigned_upload), without exposing your apiKey or
secretKey.

## Getting started

Add the dependency `cloudinary_public: ^0.13.0` to your project:

```dart
import 'package:cloudinary_public/cloudinary_public.dart';

final cloudinary = CloudinaryPublic('CLOUD_NAME', 'UPLOAD_PRESET', cache: false);
```

Check https://cloudinary.com/documentation/upload_images#unsigned_upload on how to create an upload preset.

### Using [Image Picker](https://pub.dev/packages/image_picker) Plugin

```
var image = await ImagePicker.pickImage(source: ImageSource.camera);

try {
    CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
    );
    
    print(response.secureUrl);
} on CloudinaryException catch (e) {
  print(e.message);
  print(e.request);
}
```

### Using [Multi Image Picker](https://pub.dev/packages/multi_image_picker) Plugin

```
final images = await MultiImagePicker.pickImages(maxImages: 4);

List<CloudinaryResponse> uploadedImages = await cloudinary.multiUpload(
images
    .map(
      (image) => CloudinaryFile.fromFutureByteData(
        image.getByteData(),
        identifier: image.identifier,
      ),
    )
    .toList(),
);

print(uploadedImages[0].secureUrl);
```

## Image Transformation

```dart
// CloudinaryImage
final cloudinaryImage = CloudinaryImage('https://res.cloudinary.com/demo/image/upload/front_face.png');
// or using the image public id
final cloudinaryImage = cloudinary.getImage('front_face');

final String url = cloudinaryImage.transform().width(150).height(150).gravity('face').crop('thumb').generate();
// or using the shortcut
final String url = cloudinaryImage.thumbnail(width: 150, height: 150).generate();


// Chain example
final url = cloudinaryImage.transform()
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
// generates
// https://res.cloudinary.com/demo/image/upload/c_thumb,g_face,h_150,w_150/r_20/e_sepia/e_brightness:200,g_south_east,l_cloudinary_icon,o_60,w_50,x_5,y_5/a_10/front_face.png
```

## Upload Progress
```dart
final res = await cloudinary.uploadFile(
  CloudinaryFile.fromFile(
    _pickedFile.path,
    folder: 'hello-folder',
    context: {
      'alt': 'Hello',
      'caption': 'An example image',
    },
  ),
  onProgress: (count, total) {
    setState(() {
      _uploadingPercentage = (count / total) * 100;
    });
  },
);
```