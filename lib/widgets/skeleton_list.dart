import 'package:flutter/material.dart';
import 'skeleton_card.dart';

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 7,
      separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
      itemBuilder: (_, i) => SkeletonCard(
        delay: Duration(milliseconds: i * 120),
      ),
    );
  }
}
