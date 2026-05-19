import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';

class LoadingList extends StatelessWidget {
  const LoadingList({this.itemCount = 5, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceAlt,
      highlightColor: AppColors.surface,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: 92,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
