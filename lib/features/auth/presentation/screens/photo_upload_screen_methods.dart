// These are the methods to add to photo_upload_screen.dart

/// Cache the current photo state to SharedPreferences
Future<void> _cachePhotoState() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Store paths to photos if they exist
    if (_selfiePhoto != null) {
      await prefs.setString('cached_selfie_photo', _selfiePhoto!.path);
    }
    
    if (_frontIdPhoto != null) {
      await prefs.setString('cached_front_id_photo', _frontIdPhoto!.path);
    }
    
    if (_backIdPhoto != null) {
      await prefs.setString('cached_back_id_photo', _backIdPhoto!.path);
    }
  } catch (e) {
    // Silently handle caching errors
    debugPrint('Error caching photo state: $e');
  }
}

/// Load cached photo state from SharedPreferences
Future<void> _loadCachedPhotoState() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Load photo paths if they exist
    final selfiePath = prefs.getString('cached_selfie_photo');
    final frontIdPath = prefs.getString('cached_front_id_photo');
    final backIdPath = prefs.getString('cached_back_id_photo');
    
    // Only set state if we're mounted and paths exist
    if (mounted) {
      setState(() {
        // Create File objects from paths if they exist
        if (selfiePath != null) {
          final file = File(selfiePath);
          if (file.existsSync()) {
            _selfiePhoto = file;
          }
        }
        
        if (frontIdPath != null) {
          final file = File(frontIdPath);
          if (file.existsSync()) {
            _frontIdPhoto = file;
          }
        }
        
        if (backIdPath != null) {
          final file = File(backIdPath);
          if (file.existsSync()) {
            _backIdPhoto = file;
          }
        }
      });
    }
  } catch (e) {
    // Silently handle loading errors
    debugPrint('Error loading cached photo state: $e');
  }
}
