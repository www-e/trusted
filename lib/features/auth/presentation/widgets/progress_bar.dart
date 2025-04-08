import 'package:flutter/material.dart';
import 'package:trusted/core/theme/colors.dart';

/// A progress bar widget for multi-step processes
class StepProgressBar extends StatelessWidget {
  /// Current step (1-based index)
  final int currentStep;
  
  /// Total number of steps
  final int totalSteps;
  
  /// Labels for each step
  final List<String> stepLabels;

  /// Constructor
  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  }) : assert(stepLabels.length == totalSteps, 
             'Number of labels must match total steps');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;
    
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index + 1 < currentStep;
            final isActive = index + 1 == currentStep;
            
            return Expanded(
              child: Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted || isActive
                            ? AppColors.primary
                            : isLightMode
                                ? AppColors.lightBorder
                                : AppColors.darkBorder,
                      ),
                    ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.primary
                          : isActive
                              ? AppColors.primary.withOpacity(0.2)
                              : isLightMode
                                  ? AppColors.lightBackground
                                  : AppColors.darkBackground,
                      border: Border.all(
                        color: isCompleted || isActive
                            ? AppColors.primary
                            : isLightMode
                                ? AppColors.lightBorder
                                : AppColors.darkBorder,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? AppColors.primary
                                    : isLightMode
                                        ? AppColors.darkText
                                        : AppColors.lightText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  if (index < totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted
                            ? AppColors.primary
                            : isLightMode
                                ? AppColors.lightBorder
                                : AppColors.darkBorder,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            final isActive = index + 1 == currentStep;
            
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  stepLabels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive
                        ? AppColors.primary
                        : isLightMode
                            ? AppColors.darkText.withOpacity(0.7)
                            : AppColors.lightText.withOpacity(0.7),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
