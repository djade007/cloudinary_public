class CloudinaryResponse {
  final String assetId;
  final String publicId;
  final DateTime createdAt;
  final String url;
  final String secureUrl;
  final String originalFilename;

  CloudinaryResponse({
    this.assetId,
    this.publicId,
    this.createdAt,
    this.url,
    this.secureUrl,
    this.originalFilename,
  });

  factory CloudinaryResponse.fromMap(Map<String, dynamic> data) {
    return CloudinaryResponse(
      assetId: data['asset_id'],
      publicId: data['public_id'],
      createdAt: DateTime.parse(data['created_at']),
      url: data['url'],
      secureUrl: data['secure_url'],
      originalFilename: data['original_filename'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'asset_id': assetId,
      'public_id': publicId,
      'created_at': createdAt.toString(),
      'url': url,
      'secure_url': secureUrl,
      'original_filename': originalFilename
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}