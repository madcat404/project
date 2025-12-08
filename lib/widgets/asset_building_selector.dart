// 파일 경로: lib/widgets/asset_building_selector.dart
import 'package:flutter/material.dart';
import 'package:project/models/asset_models.dart';

class AssetBuildingSelector extends StatelessWidget {
  final List<Building> buildings;
  final int selectedIndex;
  final Function(int) onSelected;
  final ScrollController scrollController;
  final bool isLandscape;

  const AssetBuildingSelector({
    super.key,
    required this.buildings,
    required this.selectedIndex,
    required this.onSelected,
    required this.scrollController,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    final double textScaleFactor = isLandscape ? 1.2 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('보유 건물 현황', style: TextStyle(fontSize: 18 * textScaleFactor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: selectedIndex > 0 ? () => onSelected(selectedIndex - 1) : null,
            ),
            Expanded(
              child: SizedBox(
                height: 100 * textScaleFactor,
                child: ListView.separated(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: buildings.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final building = buildings[index];
                    final isSelected = index == selectedIndex;
                    return InkWell(
                      onTap: () => onSelected(index),
                      child: Card(
                        elevation: 2,
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelected ? BorderSide(color: Colors.blue.shade300, width: 2) : BorderSide.none,
                        ),
                        child: Container(
                          width: 200 * textScaleFactor,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(building.name, style: TextStyle(fontSize: 16 * textScaleFactor, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text(building.address, style: TextStyle(fontSize: 12 * textScaleFactor, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
                              Text.rich(
                                TextSpan(
                                  style: TextStyle(fontSize: 12 * textScaleFactor, color: Colors.grey[600]),
                                  children: [
                                    const TextSpan(text: '총 '),
                                    TextSpan(text: '${building.totalUnits}', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                                    const TextSpan(text: '호실 / 공실 '),
                                    TextSpan(text: '${building.vacantUnits}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: selectedIndex < buildings.length - 1 ? () => onSelected(selectedIndex + 1) : null,
            )
          ],
        )
      ],
    );
  }
}