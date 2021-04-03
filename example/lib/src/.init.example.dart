import 'package:cloudinary_public/cloudinary_public.dart';

// copy file to init.dart
final cloudinary = CloudinaryPublic(
  'Your-Cloud-Name',
  // See https://cloudinary.com/documentation/upload_images#unsigned_upload on to create an upload preset
  'Your-Upload-Preset',
  cache: true,
);
