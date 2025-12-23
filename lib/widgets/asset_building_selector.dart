import 'package:flutter/material.dart';
import 'package:project/models/asset_models.dart';
// [추가] 상세 화면 연결을 위해 import
import 'package:project/screens/asset_building_details_screen.dart';

class AssetBuildingSelector extends StatelessWidget {
  final List<Building> buildings;
  final int selectedIndex;
  final Function(int) onSelected;
  final ScrollController scrollController;
  final double scaleFactor;

  const AssetBuildingSelector({
    super.key,
    required this.buildings,
    required this.selectedIndex,
    required this.onSelected,
    required this.scrollController,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final double textScaleFactor = scaleFactor;

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
                height: 130 * textScaleFactor,
                child: ListView.separated(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: buildings.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final building = buildings[index];
                    final isSelected = index == selectedIndex;

                    // 카드 전체 클릭 시: 하단 리스트 갱신 (선택)
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
                          width: 220 * textScaleFactor,
                          padding: EdgeInsets.all(16.0 * textScaleFactor),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // [수정] 건물명 부분을 클릭하면 상세페이지로 이동
                              InkWell(
                                onTap: () {
                                  // 상세 화면으로 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AssetBuildingDetailsScreen(building: building),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.business, size: 20 * textScaleFactor, color: isSelected ? Colors.blueAccent : Colors.grey),
                                    SizedBox(width: 8 * textScaleFactor),
                                    Expanded(
                                      child: Text(
                                          building.name,
                                          style: TextStyle(
                                            fontSize: 16 * textScaleFactor,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline, // 클릭 가능함을 암시
                                            decorationColor: Colors.grey[400],
                                            decorationStyle: TextDecorationStyle.dotted,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis
                                      ),
                                    ),
                                    // 이동 아이콘 추가
                                    Icon(Icons.arrow_circle_right_outlined, size: 18 * textScaleFactor, color: Colors.blueAccent),
                                  ],
                                ),
                              ),

                              // 주소 및 호실 정보 (여기는 클릭해도 상세로 안 가고 선택만 됨)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      building.address,
                                      style: TextStyle(fontSize: 12 * textScaleFactor, color: Colors.grey[600]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis
                                  ),
                                  SizedBox(height: 4 * textScaleFactor),
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
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