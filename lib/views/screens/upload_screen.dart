import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibes/services/content_moderation.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedFile;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Pick video from gallery or camera
  pickVideo(ImageSource src) async {
    final video = await ImagePicker().pickVideo(source: src);
    if (video != null) {
      setState(() {
        _selectedFile = File(video.path);
      });
    }
  }

  // Show options dialog for picking video
  showOptionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              pickVideo(ImageSource.gallery);
            },
            child: Row(
              children: const [
                Icon(Icons.image, color: Colors.deepPurple),
                Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              pickVideo(ImageSource.camera);
            },
            child: Row(
              children: const [
                Icon(Icons.camera_alt, color: Colors.deepPurple),
                Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(),
            child: Row(
              children: const [
                Icon(Icons.cancel, color: Colors.deepPurple),
                Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Upload video to Firebase Storage and save metadata to Firestore
  Future<void> _uploadVideo() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video first')),
      );
      return;
    }

    // Check if the video is safe using content moderation
    final bool isSafe =
        await ContentModeration.isVideoSafe(_selectedFile!.path);

    if (!isSafe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Video contains inappropriate content and cannot be uploaded')),
      );
      return;
    }

    // Upload the video to Firebase Storage
    try {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('videos/${DateTime.now().millisecondsSinceEpoch}.mp4');
      await storageRef.putFile(_selectedFile!);

      // Get the download URL
      final String downloadUrl = await storageRef.getDownloadURL();

      // Save video metadata to Firestore
      await FirebaseFirestore.instance.collection('videos').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'url': downloadUrl,
        'timestamp': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully!')),
      );

      // Clear the form
      setState(() {
        _selectedFile = null;
        _titleController.clear();
        _descriptionController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload video: $e')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Upload Area
            GestureDetector(
              onTap: () => showOptionsDialog(context),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade900,
                  border: Border.all(
                    color: Colors.grey.shade800,
                    width: 2,
                  ),
                ),
                child: _selectedFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cloud_upload,
                              size: 50, color: Colors.deepPurple),
                          SizedBox(height: 10),
                          Text(
                            'Tap to select video',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: const [
                          Icon(Icons.videocam,
                              size: 50, color: Colors.deepPurple),
                          Positioned(
                            bottom: 10,
                            child: Text(
                              'Video selected',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade800),
                ),
                filled: true,
                fillColor: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 16),
            // Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade800),
                ),
                filled: true,
                fillColor: Colors.grey.shade900,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            // Upload Button
            ElevatedButton.icon(
              onPressed: _uploadVideo,
              icon: const Icon(Icons.upload),
              label: const Text('Upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
