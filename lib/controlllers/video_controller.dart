import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vibes/constants.dart';
import 'package:vibes/models/video.dart';

class VideoController extends GetxController {
  final Rx<List<Video>> _videoList = Rx<List<Video>>([]);

  List<Video> get videoList => _videoList.value;

  @override
  void onInit() {
    super.onInit();
    fetchVideos(); // Fetch videos when the controller is initialized
    _videoList.bindStream(
      firestore.collection('videos').snapshots().map((QuerySnapshot query) {
        List<Video> retVal = [];
        for (var element in query.docs) {
          retVal.add(
            Video.fromSnap(element),
          );
        }
        return retVal;
      }),
    );
  }

  // Explicit function to fetch videos
  Future<void> fetchVideos() async {
    try {
      final QuerySnapshot snapshot = await firestore.collection('videos').get();
      final List<Video> videos = snapshot.docs.map((doc) {
        return Video.fromSnap(doc);
      }).toList();
      _videoList.value = videos; // Update the video list
    } catch (e) {
      print('Error fetching videos: $e');
    }
  }

  // Like video function
  likeVideo(String id) async {
    DocumentSnapshot doc = await firestore.collection('videos').doc(id).get();
    var uid = authController.user.uid;
    if ((doc.data()! as dynamic)['likes'].contains(uid)) {
      await firestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      await firestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
  }
}
