import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ContentModeration {
  static Future<bool> isVideoSafe(String videoPath) async {
    // Extract a thumbnail from the video
    final XFile? thumbnailFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    // Check if the user canceled the image picker
    if (thumbnailFile == null) {
      print('No thumbnail selected.');
      return false;
    }

    // Send the thumbnail to Google Cloud Vision API
    final String apiUrl =
        'https://vision.googleapis.com/v1/images:annotate?key=API_KEY';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        "requests": [
          {
            "image": {
              "source": {
                "imageUri": thumbnailFile.path,
              },
            },
            "features": [
              {
                "type": "SAFE_SEARCH_DETECTION",
              },
            ],
          },
        ],
      }),
    );

    final data = jsonDecode(response.body);
    final safeSearchAnnotation = data['responses'][0]['safeSearchAnnotation'];

    // Check for adult, violence, or racy content
    if (safeSearchAnnotation['adult'] == 'VERY_LIKELY' ||
        safeSearchAnnotation['violence'] == 'VERY_LIKELY' ||
        safeSearchAnnotation['racy'] == 'VERY_LIKELY') {
      return false; // Unsafe content
    }
    return true; // Safe content
  }
}
