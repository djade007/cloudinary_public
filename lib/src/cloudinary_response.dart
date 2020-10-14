/// Class to be used to format response from the cloudinary api
class CloudinaryResponse {
  final String assetId;
  final String publicId;
  final DateTime createdAt;
  final String url;
  final String secureUrl;
  final String originalFilename;
  final List<String> tags;
  final bool fromCache;

  CloudinaryResponse({
    this.assetId,
    this.publicId,
    this.createdAt,
    this.url,
    this.secureUrl,
    this.originalFilename,
    this.tags,
    this.fromCache: false,
  });

  /// Instantiate this class from a map data
  factory CloudinaryResponse.fromMap(Map<String, dynamic> data) {
    return CloudinaryResponse(
      assetId: data['asset_id'],
      publicId: data['public_id'],
      createdAt: DateTime.parse(data['created_at']),
      url: data['url'],
      secureUrl: data['secure_url'],
      originalFilename: data['original_filename'],
      tags: data['tags'] != null
          ? (data['tags'] as List).map((tag) => tag as String).toList()
          : [],
    );
  }

  /// Sets the [fromCache] property to true
  CloudinaryResponse enableCache() {
    return CloudinaryResponse(
      assetId: assetId,
      publicId: publicId,
      createdAt: createdAt,
      url: url,
      secureUrl: secureUrl,
      originalFilename: originalFilename,
      tags: tags,
      fromCache: true,
    );
  }

  /// Convert the class to a map instance
  Map<String, dynamic> toMap() {
    return {
      'asset_id': assetId,
      'public_id': publicId,
      'created_at': createdAt.toString(),
      'url': url,
      'secure_url': secureUrl,
      'original_filename': originalFilename,
      'tags': tags,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
