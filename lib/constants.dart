import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vibes/controlllers/auth_controller.dart';
import 'package:vibes/views/screens/upload_screen.dart';
import 'package:vibes/views/screens/video_screen.dart';

List pages = [
  VideoScreen(),
  Text('Search Screen'),
  const UploadScreen(),
  Text('Messages Screen'),
  Text('Profile Screen'),
];

// Colors

const backgroundColor = Colors.black;
var buttonColor = Colors.deepPurple;
const borderColor = Colors.blueGrey;

// Firebase

var firebaseAuth = FirebaseAuth.instance;
var firebaseStorage = FirebaseStorage.instance;
var firestore = FirebaseFirestore.instance;

// CONTROLLER
var authController = AuthController.instance;
