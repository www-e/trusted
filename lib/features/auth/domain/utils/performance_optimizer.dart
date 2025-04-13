import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A utility class for optimizing performance in the app
class PerformanceOptimizer {
  /// Singleton instance
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  
  /// Private constructor
  PerformanceOptimizer._internal();
  
  /// Factory constructor to return the singleton instance
  factory PerformanceOptimizer() => _instance;
  
  /// Map to store debouncers
  final Map<String, Timer> _debouncers = {};
  
  /// Debounce a function call with a unique key
  /// This prevents excessive rebuilds and UI updates
  void debounceWithKey(String key, VoidCallback action, [Duration duration = const Duration(milliseconds: 300)]) {
    if (_debouncers.containsKey(key)) {
      _debouncers[key]?.cancel();
    }
    
    _debouncers[key] = Timer(duration, () {
      action();
      _debouncers.remove(key);
    });
  }
  
  /// Cancel all active debouncers
  void cancelAllDebouncers() {
    _debouncers.forEach((key, timer) => timer.cancel());
    _debouncers.clear();
  }
  
  /// Run a function in the next frame to avoid jank
  void runInNextFrame(VoidCallback action) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      action();
    });
  }
  
  /// Run a heavy operation with optimized scheduling
  /// This helps prevent UI freezes during complex operations
  void runHeavyOperation(VoidCallback action) {
    SchedulerBinding.instance.scheduleTask(
      action,
      Priority.animation,
    );
  }
  
  /// Optimize a widget by wrapping it in performance-enhancing containers
  Widget optimizeWidget(Widget widget) {
    return RepaintBoundary(
      child: widget,
    );
  }
  
  /// Create an optimized scroll view that minimizes rebuilds
  Widget createOptimizedScrollView({
    required List<Widget> children,
    bool addRepaintBoundaries = true,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
  }) {
    final optimizedChildren = addRepaintBoundaries
        ? children.map((child) => RepaintBoundary(child: child)).toList()
        : children;
    
    return ListView.builder(
      itemCount: optimizedChildren.length,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      padding: padding,
      itemBuilder: (context, index) => optimizedChildren[index],
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
    );
  }
  
  /// Optimize form fields to prevent excessive rebuilds
  Widget optimizeFormField(Widget formField, String fieldId) {
    return RepaintBoundary(
      key: ValueKey('form_field_$fieldId'),
      child: formField,
    );
  }
}
