import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String id;
  final String username;
  final String caption;
  final String videoUrl;
  final String profilePhoto;
  final List<String> likes;
  final int commentCount;
  final int shareCount;
  final String songName;
  final String thumbnailUrl; // Add this field

  Video({
    required this.id,
    required this.username,
    required this.caption,
    required this.videoUrl,
    required this.profilePhoto,
    required this.likes,
    required this.commentCount,
    required this.shareCount,
    required this.songName,
    required this.thumbnailUrl, // Add this field
  });

  // Convert a Video object into a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'caption': caption,
      'videoUrl': videoUrl,
      'profilePhoto': profilePhoto,
      'likes': likes,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'songName': songName,
      'thumbnailUrl': thumbnailUrl, // Add this field
    };
  }

  // Factory constructor to create a Video object from a Firestore document snapshot
  factory Video.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Video(
      id: snap.id,
      username: snapshot['username'],
      caption: snapshot['caption'],
      videoUrl: snapshot['videoUrl'],
      profilePhoto: snapshot['profilePhoto'],
      likes: List<String>.from(snapshot['likes']),
      commentCount: snapshot['commentCount'],
      shareCount: snapshot['shareCount'],
      songName: snapshot['songName'],
      thumbnailUrl: snapshot['thumbnailUrl'], // Add this field
    );
  }
}
