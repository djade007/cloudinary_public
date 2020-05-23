# cloudinary_public

This package allows you to upload media files directly to [cloudinary](https://cloudinary.com/documentation/upload_images#unsigned_upload), without exposing your apiKey or secretKey.

## ️ Getting started

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

