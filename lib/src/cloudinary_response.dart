/// Class to be used to format response from the cloudinary api
class CloudinaryResponse {
  final String assetId;
  final String publicId;
  final DateTime createdAt;
  final String url;
  final String secureUrl;
  final String originalFilename;
  final List<String> tags;
  final Map<String, dynamic> context;
  final bool fromCache;

  /// Extract and return the image context
  Map<String, String> get customContext {
    if (context['custom'] != null) return Map.castFrom(context['custom']);

    return {};
  }

  CloudinaryResponse({
    required this.assetId,
    required this.publicId,
    required this.createdAt,
    required this.url,
    required this.secureUrl,
    required this.originalFilename,
    this.tags: const [],
    this.context: const {},
    this.fromCache: false,
  });

  /// Instantiate this class from a map data
  factory CloudinaryResponse.fromMap(Map<String, dynamic> data) {
    return CloudinaryResponse(
      assetId: data['asset_id'] ?? '',
      publicId: data['public_id'] ?? '',
      createdAt: DateTime.parse(data['created_at']),
      url: data['url'] ?? '',
      secureUrl: data['secure_url'] ?? '',
      originalFilename: data['original_filename'] ?? '',
      tags: data['tags'] != null
          ? (data['tags'] as List).map((tag) => tag as String).toList()
          : [],
      context: data['context'] is Map ? data['context'] : {},
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
      context: context,
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
      'context': context,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
