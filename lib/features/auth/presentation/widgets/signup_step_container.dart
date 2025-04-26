import 'package:flutter/material.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/auth/domain/utils/performance_optimizer.dart';

/// A reusable container widget for signup steps
class SignupStepContainer extends StatelessWidget {
  /// The title of the step
  final String title;
  
  /// The subtitle or description of the step
  final String subtitle;
  
  /// The child widget to display in the container
  final Widget child;
  
  /// The current step number
  final int currentStep;
  
  /// The total number of steps
  final int totalSteps;
  
  /// The step labels to display in the progress bar
  final List<String> stepLabels;
  
  /// Callback when the next button is pressed
  final VoidCallback onNext;
  
  /// Callback when the back button is pressed
  final VoidCallback? onBack;
  
  /// Text for the next button
  final String nextButtonText;
  
  /// Whether the next button is enabled
  final bool isNextEnabled;
  
  /// Whether to show the back button
  final bool showBackButton;
  
  /// Whether the step is in loading state
  final bool isLoading;

  /// Constructor
  const SignupStepContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
    required this.onNext,
    this.onBack,
    this.nextButtonText = 'التالي',
    this.isNextEnabled = true,
    this.showBackButton = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final FocusScopeNode currentFocus = FocusScope.of(context);
    
    // Use a combination of PopScope and focus handling for reliable back navigation
    return PopScope(
      canPop: false, // Never allow automatic pop to ensure we handle navigation ourselves
      onPopInvoked: (didPop) {
        // If the back button is pressed and we have an onBack handler
        if (!didPop && showBackButton && currentStep > 1 && onBack != null) {
          // Unfocus any text fields first to prevent keyboard issues
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          
          // Small delay to ensure UI is ready before navigation
          Future.microtask(() {
            onBack!();
          });
        }
      },
      child: Scaffold(
        // Use resizeToAvoidBottomInset to prevent keyboard from pushing content
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('التسجيل - الخطوة $currentStep من $totalSteps'),
          centerTitle: true,
          leading: showBackButton && currentStep > 1
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                )
              : null,
        ),
        // Wrap in GestureDetector to handle taps outside input fields
        body: GestureDetector(
          onTap: () {
            // Only unfocus if not tapping on a text field
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          // Add RepaintBoundary to optimize rendering
          child: RepaintBoundary(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress bar
                    _buildProgressBar(context),
                    
                    const SizedBox(height: 24),
                    
                    // Step title
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Step subtitle
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Step content with performance optimization
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          // Optimize scroll performance
                          return true; // Prevents notification bubbling
                        },
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(), // Better performance than bouncing
                          child: PerformanceOptimizer().optimizeWidget(child),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Next button
                    ElevatedButton(
                      onPressed: isNextEnabled && !isLoading ? onNext : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(nextButtonText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the progress bar widget
  Widget _buildProgressBar(BuildContext context) {
    // Icons for each step
    final List<IconData> stepIcons = [
      Icons.person_outline, // Role selection
      Icons.info_outline,   // Basic info
      Icons.phone_android,  // Contact info
      if (totalSteps > 4) Icons.photo_camera, // Photos (only for merchant/mediator)
      Icons.lock_outline,   // Account creation
    ];
    
    // Use RepaintBoundary to optimize rendering of the progress bar
    return RepaintBoundary(
      child: Column(
      children: [
        // Progress line
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index < currentStep;
            final isCurrent = index == currentStep - 1;
            
            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(
                  right: index < totalSteps - 1 ? 4 : 0,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: isCurrent
                    ? LinearProgressIndicator(
                        backgroundColor: AppColors.primary,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary.withOpacity(0.5),
                        ),
                      )
                    : null,
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        
        // Step indicators with icons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            final isActive = index < currentStep;
            final isCurrent = index == currentStep - 1;
            final isCompleted = index < currentStep - 1;
            
            return Expanded(
              child: Column(
                children: [
                  // Step icon or number
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : Icon(
                              stepIcons[index],
                              color: isActive ? Colors.white : Colors.grey,
                              size: 18,
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Step label (short version)
                  Text(
                    _getShortLabel(stepLabels[index]),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? AppColors.primary : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    ),
    );
  }
  
  /// Get a shortened version of the step label
  String _getShortLabel(String label) {
    final words = label.split(' ');
    if (words.length > 1) {
      return words[0];
    }
    return label;
  }
}