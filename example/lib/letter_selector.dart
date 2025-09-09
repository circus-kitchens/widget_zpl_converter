import 'package:flutter/material.dart';

enum SiloSectionType { a, b, c, d, e, f }

const _selectedLetterSize = 4.6;
const _unselectedLetterSize = 2.6;

class LetterSelector extends StatelessWidget {
  const LetterSelector({
    required this.selectedSectionType,
    required this.sizingUnit,
    super.key,
  });

  final SiloSectionType? selectedSectionType;
  final double sizingUnit;

  @override
  Widget build(BuildContext context) {
    final backgroundPrimary = Colors.black;
    final backgroundSecondary = Colors.grey;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: SiloSectionType.values.map((sectionType) {
          final isSelected = sectionType == selectedSectionType;
          return Container(
            height:
                (isSelected ? _selectedLetterSize : _unselectedLetterSize) *
                sizingUnit,
            width:
                (isSelected ? _selectedLetterSize : _unselectedLetterSize) *
                sizingUnit,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? backgroundPrimary : backgroundSecondary,
              ),
            ),
            child: Text(
              sectionType.name,
              style: isSelected
                  ? TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: backgroundPrimary,
                    )
                  : TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: backgroundSecondary,
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
