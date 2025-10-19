import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/firebase_config.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery
  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      print('Pick image error: $e');
      return null;
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage({
    required String userId,
    required XFile image,
  }) async {
    try {
      final ref = _storage.ref().child('${FirebaseConfig.userProfilesPath}$userId.jpg');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Upload profile image error: $e');
      return null;
    }
  }

  // Upload gig images
  Future<List<String>> uploadGigImages({
    required String gigId,
    required List<XFile> images,
  }) async {
    try {
      final List<String> urls = [];

      for (int i = 0; i < images.length; i++) {
        final ref = _storage.ref().child('${FirebaseConfig.gigsImagesPath}${gigId}_$i.jpg');
        await ref.putFile(File(images[i].path));
        final url = await ref.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      print('Upload gig images error: $e');
      return [];
    }
  }

  // Delete image
  Future<void> deleteImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      print('Delete image error: $e');
    }
  }
}
