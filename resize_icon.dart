// A simple Dart script to resize the app icon to proper dimensions
// Run this with: dart resize_icon.dart

import 'dart:io';
import 'package:image/image.dart';

void main() async {
  // Load the original image
  final originalImagePath = 'assets/images/app_icon.png';
  final File originalFile = File(originalImagePath);
  
  if (!originalFile.existsSync()) {
    print('Error: Original icon file not found at $originalImagePath');
    return;
  }
  
  // Read the image
  final imageBytes = await originalFile.readAsBytes();
  final originalImage = decodeImage(imageBytes);
  
  if (originalImage == null) {
    print('Error: Could not decode the image');
    return;
  }
  
  // Resize to 1024x1024 (standard size for app icons)
  final resizedImage = copyResize(
    originalImage,
    width: 1024,
    height: 1024,
    interpolation: Interpolation.average,
  );
  
  // Create a backup of the original file
  final backupPath = 'assets/images/app_icon_original.png';
  await originalFile.copy(backupPath);
  print('Original icon backed up to $backupPath');
  
  // Save the resized image
  final resizedFile = File(originalImagePath);
  await resizedFile.writeAsBytes(encodePng(resizedImage));
  
  print('Icon resized to 1024x1024 and saved to $originalImagePath');
  print('Run "flutter pub run flutter_launcher_icons" to update your app icons');
}
