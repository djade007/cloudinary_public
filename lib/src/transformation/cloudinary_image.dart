import 'transformation.dart';

class CloudinaryImage {
  static const String _baseUrl =
      'https://res.cloudinary.com/:cloud/image/upload/';

  late String _path;
  late String _publicId;
  late String _originalUrl;

  String get url => _originalUrl;

  String get publicId => _publicId;

  CloudinaryImage(String url) {
    // remove version
    _originalUrl = url.replaceFirst(RegExp(r"v\d+/"), '');

    final resource = url.split('/upload/');
    assert(resource.length == 2, 'Invalid cloudinary url');
    _path = resource[0] + '/upload/';
    _publicId = resource[1];
  }

  factory CloudinaryImage.fromPublicId(String cloudName, String publicId) {
    return CloudinaryImage(
      _baseUrl.replaceFirst(':cloud', cloudName) + publicId,
    );
  }

  Transformation transform() {
    return Transformation(_path, _publicId);
  }

  Transformation thumbnail({int width: 200, int height: 200}) {
    return transform()
        .width(width)
        .height(height)
        .crop('thumb')
        .gravity('face');
  }

  @override
  String toString() {
    return _originalUrl;
  }
}
