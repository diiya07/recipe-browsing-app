import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerRecipeList extends StatelessWidget {
  const ShimmerRecipeList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the current theme brightness to adjust shimmer colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;

        if (isWide) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: 380,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => _buildShimmerItem(baseColor, highlightColor),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildShimmerItem(baseColor, highlightColor),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerItem(Color baseColor, Color highlightColor) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
