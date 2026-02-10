import 'package:flutter/material.dart';
import 'package:storelytics/theme/app_colors.dart';
import 'package:storelytics/theme/app_spacing.dart';

/// Alert badge for low stock or expiry warnings.
class AlertBadge extends StatelessWidget {
  final String text;
  final AlertType type;

  const AlertBadge({
    super.key,
    required this.text,
    this.type = AlertType.warning,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      AlertType.danger => AppColors.loss,
      AlertType.warning => AppColors.warning,
      AlertType.success => AppColors.profit,
      AlertType.info => AppColors.secondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

enum AlertType { danger, warning, success, info }

/// Section header for dashboard sections.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
      ],
    );
  }
}
