import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.mealTypes.length,
        itemBuilder: (context, index) {
          final type = AppConstants.mealTypes[index];
          final isSelected = type == selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onFilterSelected(type);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
