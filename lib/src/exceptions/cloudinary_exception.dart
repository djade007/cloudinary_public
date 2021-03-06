import 'dart:convert';

/// Holds the http response error from the cloudinary api
class CloudinaryException implements Exception {
  /// full response string from cloudinary
  final String responseString;

  /// http status code from cloudinary
  final int statusCode;

  /// file information.
  /// It can be used to identify the exact uploaded file that fails during multi upload
  /// contains {url, path, identifier}
  final Map<String, dynamic> request;

  /// Extract the error message from cloudinary
  String get message {
    try {
      return jsonDecode(responseString)['error']['message'];
    } catch (e) {
      // unable to extract error message
      return null;
    }
  }

  /// Creates a new `CloudinaryException` with an optional file info [request]
  CloudinaryException(this.responseString, this.statusCode, {this.request});

  /// `CloudinaryException` summary
  String toString() {
    return '($statusCode) ${message ?? responseString}';
  }
}
