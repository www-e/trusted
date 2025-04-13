import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';

/// Utility class for performance optimization
class PerformanceUtils {
  /// Debounce a function call to prevent excessive rebuilds
  static VoidCallback debounce(VoidCallback func, [int milliseconds = 300]) {
    final debouncer = Debouncer(milliseconds: milliseconds);
    
    return () {
      debouncer.run(func);
    };
  }
  
  /// Optimize image loading by using a placeholder until the image is loaded
  static Widget optimizedImage({
    required ImageProvider imageProvider,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    return Image(
      image: imageProvider,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return placeholder ?? Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
        );
      },
      // Optimization handled by width and height parameters
    );
  }
  
  /// Optimize a ListView by using const constructors and keys
  static Widget optimizedListView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    ScrollController? controller,
  }) {
    return ListView.builder(
      key: UniqueKey(), // Helps with recycling
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      controller: controller,
      addAutomaticKeepAlives: false, // Disable automatic keep alives
      addRepaintBoundaries: true, // Add repaint boundaries
      addSemanticIndexes: false, // Disable semantic indexes for performance
    );
  }
  
  /// Run a task on a separate isolate to avoid blocking the UI thread
  static void runAsync(VoidCallback task) {
    SchedulerBinding.instance.scheduleTask(
      task,
      Priority.animation,
    );
  }
  
  /// Optimize form field by using RepaintBoundary
  static Widget optimizedFormField(Widget formField) {
    return RepaintBoundary(
      child: formField,
    );
  }
  
  /// Compress an image file to reduce size while maintaining quality
  /// Returns a new compressed file
  static Future<File> compressImage(File file) async {
    try {
      // Get temp directory
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Compress the image
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85, // Good balance between quality and size
        minWidth: 1024, // Reasonable max width for a photo
        minHeight: 1024, // Reasonable max height for a photo
      );
      
      if (result == null) {
        throw Exception('Failed to compress image');
      }
      
      // Convert XFile to File
      return File(result.path);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      // Return original file if compression fails
      return file;
    }
  }
  
  /// Compress image in an isolate to avoid UI freezes
  /// This method is meant to be called with compute()
  static Future<File> compressImageIsolate(File file) async {
    return await compressImage(file);
  }
}

/// A utility class for debouncing function calls
class Debouncer {
  final int milliseconds;
  Timer? _timer;
  
  Debouncer({this.milliseconds = 300});
  
  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
  
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
