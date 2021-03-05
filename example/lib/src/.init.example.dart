import 'package:cloudinary_public/cloudinary_public.dart';

// copy file to init.dart
final cloudinary = CloudinaryPublic(
  'Your-Cloud-Name',
  'Your-Upload-Preset',
  cache: true,
);
