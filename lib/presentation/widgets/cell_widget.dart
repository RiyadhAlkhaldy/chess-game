// lib/presentation/widgets/cell_widget.dart
// Material 3 + تحسينات وصول (Accessibility) + Animations + أداء

import 'package:flutter/material.dart';

import '../../domain/entities/cell.dart';

/// Widget مسؤول عن رسم مربع واحد على لوحة الشطرنج.
/// - يدعم إبراز التحديد، وإظهار الهدف القانوني للحركة، والتنبيه عند كش الملك.
/// - تم استخدام AnimatedContainer لتقليل إعادة البناء وإضافة انتقالات سلسة.
/// - تم إضافة Semantics لدعم قارئ الشاشة وإتاحة استخدام لوحة المفاتيح لاحقاً.
class CellWidget extends StatelessWidget {
  final Cell cell; // إحداثيات الخلية
  final bool isWhite; // لون المربع الأساسي
  final bool isSelected; // هل المربع محدد حالياً
  final bool isLegalMoveTarget; // هل المربع هدف قانوني للحركة
  final bool kingCellisOnCheck; // هل هذا مربع ملك في حالة كش
  final Widget? child; // قطعة الشطرنج الموجودة داخل هذا المربع (إن وجدت)
  final VoidCallback? onTap; // استجابة للنقر

  const CellWidget({
    super.key,
    required this.cell,
    required this.isWhite,
    required this.isSelected,
    required this.isLegalMoveTarget,
    required this.kingCellisOnCheck,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // اختيار اللون الخلفي بناءً على الحالة
    final Color baseLight = theme.colorScheme.surfaceContainerHighest;
    final Color baseDark = theme.colorScheme.outlineVariant;
    final Color selectedColor = theme.colorScheme.tertiaryContainer;
    final Color legalTargetColor = theme.colorScheme.secondaryContainer;
    final Color inCheckColor = theme.colorScheme.errorContainer;

    Color backgroundColor;
    if (isSelected) {
      backgroundColor = selectedColor;
    } else if (isLegalMoveTarget) {
      backgroundColor = legalTargetColor;
    } else if (kingCellisOnCheck) {
      backgroundColor = inCheckColor;
    } else {
      backgroundColor = isWhite ? baseLight : baseDark;
    }

    if (isSelected) {
      backgroundColor = Colors.yellow.shade300;
    } else if (isLegalMoveTarget) {
      backgroundColor = Colors.yellow.shade300;
    } else if (kingCellisOnCheck) {
      // backgroundColor = Colors.red.shade300; // لون أحمر لمربع الملك المهدد
    } else {
      backgroundColor =
          isWhite
              ? Colors
                  .brown
                  .shade200 // White squares background
              : Colors.brown.shade600; // Black squares background
    }
    return Semantics(
      label: 'مربع ${cell.row},${cell.col}',
      button: true,
      selected: isSelected,
      child: RepaintBoundary(
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color:
                    isSelected ? theme.colorScheme.primary : theme.dividerColor,
                width: isSelected ? 2 : 1,
              ),
              // borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // عرض نقطة صغيرة عندما يكون الهدف قانوني ولا توجد قطعة في المربع
                if (isLegalMoveTarget && child == null)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: 1,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                // القطعة (إن وجدت)
                if (child != null) child!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
