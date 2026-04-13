import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProfileStepProgress extends StatelessWidget {
  const ProfileStepProgress({
    super.key,
    required this.activeStep,
    this.totalSteps = 4,
  });

  final int activeStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < totalSteps; i++) ...[
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < activeStep
                        ? AppColors.primary
                        : const Color(0xFFC9CDD8),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              if (i != totalSteps - 1) const SizedBox(width: 6),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Шаг $activeStep из $totalSteps',
          style: textTheme.bodySmall?.copyWith(
            color: const Color(0xFFB0B5C5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
