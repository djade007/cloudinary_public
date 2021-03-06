import '../../cloudinary_public.dart';

class Transformation {
  final String _path;
  final String _publicId;
  Map<String, String> _params = {};
  List<Map<String, String>> _chains = [];

  Transformation(this._path, this._publicId);

  Transformation width(int width) {
    return param('w', width);
  }

  Transformation height(int height) {
    return param('h', height);
  }

  Transformation x(int x) {
    return param('x', x);
  }

  Transformation y(int y) {
    return param('y', y);
  }

  Transformation crop(String value) {
    return param('c', value);
  }

  Transformation gravity(String value) {
    return param('g', value);
  }

  Transformation quality(String value) {
    return param('q', value);
  }

  Transformation radius(int value) {
    return param('r', value);
  }

  Transformation angle(int angle) {
    return param('a', angle);
  }

  Transformation opacity(int value) {
    return param('o', value);
  }

  Transformation effect(String value) {
    return param('e', value);
  }

  Transformation overlay(CloudinaryImage cloudinaryImage) {
    return param('l', cloudinaryImage.publicId.replaceAll('/', ':'));
  }

  Transformation underlay(CloudinaryImage cloudinaryImage) {
    return param('u', cloudinaryImage.publicId.replaceAll('/', ':'));
  }

  String? generate() {
    if (_params.isNotEmpty) {
      _chains.add(_params);
    }

    String url = _path;

    _chains.forEach((element) {
      url += _values(element);
      url += '/';
    });

    url += _publicId;

    return url;
  }

  Transformation chain() {
    // clone
    _chains.add(Map.from(_params));
    _params.clear();
    return this;
  }

  String _values(Map<String, String> items) {
    final keys = items.keys.toList();
    keys.sort();

    List<String> values = [];

    keys.forEach((key) {
      values.add('${key}_${items[key]}');
    });

    return values.join(',');
  }

  Transformation param(String key, dynamic value) {
    if (value != null) {
      _params.addAll({key: value.toString()});
    }
    return this;
  }

  @override
  String toString() {
    return generate()!;
  }
}
