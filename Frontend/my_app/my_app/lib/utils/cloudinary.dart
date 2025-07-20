import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:crypto/crypto.dart';
import 'package:mime/mime.dart';

class CloudinaryService {
  static const String cloudName = 'dbvtwnl4j';
  static const String apiKey = '715474927499674';
  static const String apiSecret = '5Qxqum415PW6xymjAdlh4Gw3J1o';
  static const String uploadPreset = 'ml_default';

  static String extractPublicId(String imageUrl) {
    final uri = Uri.parse(imageUrl);
    final parts = uri.pathSegments;
    // Find the index of 'upload'
    final uploadIndex = parts.indexOf('upload');
    if (uploadIndex == -1) return '';
    // Everything after 'upload' is the path, possibly with version and extension
    final afterUpload = parts.sublist(uploadIndex + 1);
    // Remove version if present (starts with 'v' and is all digits after)
    if (afterUpload.isNotEmpty && afterUpload[0].startsWith('v') && int.tryParse(afterUpload[0].substring(1)) != null) {
      afterUpload.removeAt(0);
    }
    // Join the rest, remove extension
    final joined = afterUpload.join('/');
    final dot = joined.lastIndexOf('.');
    return dot == -1 ? joined : joined.substring(0, dot);
  }

  static Future<String?> uploadImageToCloudinary(File imageFile) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final mimeType = lookupMimeType(imageFile.path);
    final mimeSplit = mimeType?.split('/') ?? ['image', 'jpeg'];
    final imageUploadRequest = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      );
    try {
      final response = await imageUploadRequest.send();
      final responseData = await http.Response.fromStream(response);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Upload failed: \\${responseData.body}');
        return null;
      }
      final jsonData = json.decode(responseData.body);
      return jsonData['secure_url'];
    } catch (e) {
      print('Upload error: \\${e}');
      return null;
    }
  }

  static Future<void> deleteImageFromCloudinary(String publicId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final String toSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
    final signature = sha1.convert(utf8.encode(toSign)).toString();
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');
    final response = await http.post(
      url,
      body: {
        'public_id': publicId,
        'api_key': apiKey,
        'timestamp': timestamp.toString(),
        'signature': signature,
      },
    );
    print('Cloudinary delete response: \\${response.statusCode} \\${response.body}');
    if (response.statusCode == 200) {
      print('Deleted successfully: \\${response.body}');
    } else {
      print('Failed to delete image: \\${response.body}');
    }
  }
} 