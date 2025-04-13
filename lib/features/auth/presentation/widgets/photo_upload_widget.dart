import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trusted/core/theme/colors.dart';

/// A widget for handling photo uploads with camera
class PhotoUploadWidget extends StatefulWidget {
  /// Title to display above the photo
  final String title;
  
  /// Description or instructions for the photo
  final String description;
  
  /// Icon to display when no photo is selected
  final IconData icon;
  
  /// Callback when a photo is selected
  final Function(File) onPhotoSelected;
  
  /// Currently selected photo file
  final File? currentPhoto;
  
  /// Constructor
  const PhotoUploadWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onPhotoSelected,
    this.currentPhoto,
  });

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  File? _photoFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _photoFile = widget.currentPhoto;
  }

  @override
  void didUpdateWidget(PhotoUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPhoto != oldWidget.currentPhoto) {
      _photoFile = widget.currentPhoto;
    }
  }

  /// Take a photo using the camera
  Future<void> _takePhoto() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Reduce quality to save storage
        maxWidth: 1200,   // Limit dimensions for consistent uploads
        maxHeight: 1200,
      );
      
      if (photo != null) {
        final photoFile = File(photo.path);
        setState(() {
          _photoFile = photoFile;
        });
        widget.onPhotoSelected(photoFile);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء التقاط الصورة: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _isLoading ? null : _takePhoto,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _photoFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _photoFile!,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black54,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'تم التقاط الصورة',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: _takePhoto,
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'التقاط صورة جديدة',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.icon,
                            size: 48,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'انقر لالتقاط صورة',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}
