import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibes/models/video.dart';

class RecommendationService {
  static Future<List<Video>> getRecommendedVideos() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('videos')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();
    return snapshot.docs.map((doc) {
      return Video(
        username: doc['username'],
        id: doc['id'],
        likes: doc['likes'],
        commentCount: doc['commentCount'],
        shareCount: doc['shareCount'],
        songName: doc['songName'],
        caption: doc['caption'],
        videoUrl: doc['videoUrl'],
        profilePhoto: doc['profilePhoto'],
        thumbnailUrl: doc['thumbnailUrl'],
      );
    }).toList();
  }
}
