import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidgets {
  static Widget listShimmer() {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  static Widget tableShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          10,
          (index) => Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            height: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
