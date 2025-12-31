import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project/models/asset_models.dart';
import 'package:project/services/asset_service.dart';
import 'package:project/widgets/asset_building_selector.dart';
import 'package:project/widgets/asset_unit_card.dart';
import 'package:project/screens/asset_building_details_screen.dart';
// [추가 1] 하단 탭 클릭 시 메인 페이지로 이동하기 위해 import
import 'package:project/screens/home_page.dart';

class AssetStatusScreen extends StatefulWidget {
  final String? buildingName;
  const AssetStatusScreen({super.key, this.buildingName});

  @override
  State<AssetStatusScreen> createState() => _AssetStatusScreenState();
}

class _AssetStatusScreenState extends State<AssetStatusScreen> {
  final AssetService _assetService = AssetService();

  int _selectedBuildingIndex = 0;
  late ScrollController _scrollController;

  double _scaleFactor = 1.0;

  List<Building> _buildings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadBuildings();
  }

  // 데이터 로드 함수
  Future<void> _loadBuildings() async {
    try {
      final buildings = await _assetService.getBuildings();

      if (!mounted) return;
      setState(() {
        _buildings = buildings;
        _isLoading = false;

        if (widget.buildingName != null) {
          final index = _buildings.indexWhere((b) => b.name == widget.buildingName);
          if (index != -1) {
            _selectedBuildingIndex = index;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollToIndex(index);
              }
            });
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('데이터 로드 실패: $e')));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index) {
    const double itemWidth = 200.0;
    const double spacing = 12.0;
    final double scrollPosition = index * (itemWidth + spacing);
    _scrollController.animateTo(scrollPosition, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _addContractFromPdf() async {
    Navigator.pop(context);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true
    );
    if (result == null) return;

    if (!mounted) return;
    _showLoading();

    try {
      final fileBytes = result.files.single.bytes;
      final fileName = result.files.single.name;
      if (fileBytes == null) throw Exception('파일 로드 실패');

      final responseBody = await _assetService.uploadContractPdf(fileBytes, fileName);

      if (!mounted) return;
      Navigator.pop(context);
      await _loadBuildings();
      _showAlert('계약서 업로드 완료', '서버 응답: $responseBody');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showAlert('오류', '계약서 업로드 실패: $e');
    }
  }

  void _showLoading() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => const Center(child: CircularProgressIndicator()));
  }

  void _showAlert(String title, String content) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(title), content: SingleChildScrollView(child: Text(content)), actions: [TextButton(child: const Text('확인'), onPressed: () => Navigator.pop(ctx))]));
  }

  void _showAssetMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(children: <Widget>[
            ListTile(
                leading: const Icon(Icons.post_add),
                title: const Text('계약서 추가 (pdf)'),
                onTap: _addContractFromPdf
            ),
          ]),
        );
      },
    );
  }

  // [추가 2] 하단 탭 클릭 시 HomePage로 이동하며 해당 탭 열기 (미납관리와 동일 로직)
  void _onItemTapped(int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(initialIndex: index)),
          (Route<dynamic> route) => false,
    );
  }

  void _cycleScale() {
    setState(() {
      if (_scaleFactor == 1.0) {
        _scaleFactor = 1.2;
      } else if (_scaleFactor == 1.2) {
        _scaleFactor = 1.5;
      } else {
        _scaleFactor = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // 건물이 없을 때
    if (_buildings.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('장부관리'),
          actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: _showAssetMoreOptions)],
        ),
        body: const Center(child: Text("등록된 건물이 없습니다.")),
        // [추가 3] 여기에도 하단 바 추가
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }

    if (_selectedBuildingIndex >= _buildings.length) _selectedBuildingIndex = 0;
    final selectedBuilding = _buildings[_selectedBuildingIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.buildingName ?? '장부관리', style: TextStyle(fontSize: 18 * _scaleFactor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: '화면 확대',
            onPressed: _cycleScale,
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: _showAssetMoreOptions),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.buildingName == null) ...[
              AssetBuildingSelector(
                buildings: _buildings,
                selectedIndex: _selectedBuildingIndex,
                scrollController: _scrollController,
                scaleFactor: _scaleFactor,
                onSelected: (index) {
                  setState(() {
                    _selectedBuildingIndex = index;
                    _scrollToIndex(index);
                  });
                },
              ),
              const SizedBox(height: 24),
            ],

            InkWell(
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AssetBuildingDetailsScreen(building: selectedBuilding)
                    )
                );
                _loadBuildings();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.business, size: 24 * _scaleFactor, color: Colors.blueAccent),
                    SizedBox(width: 8 * _scaleFactor),
                    Text(
                        '${selectedBuilding.name} - 호실 현황',
                        style: TextStyle(fontSize: 18 * _scaleFactor, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(width: 4),
                    Text('(${selectedBuilding.units.length}개)', style: TextStyle(fontSize: 18 * _scaleFactor)),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios, size: 16 * _scaleFactor, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            if (selectedBuilding.units.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("등록된 호실이 없습니다.")))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedBuilding.units.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) => AssetUnitCard(
                  unit: selectedBuilding.units[i],
                  building: selectedBuilding,
                  scaleFactor: _scaleFactor,
                  allBuildings: _buildings,
                  onRefresh: () => _loadBuildings(),
                ),
              ),
          ],
        ),
      ),
      // [추가 3] 하단 바 추가
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // [추가 4] 미납관리와 똑같은 하단 바 생성 함수
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: '캐쉬'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: '상품'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: '커뮤니티'),
        BottomNavigationBarItem(icon: Icon(Icons.campaign), label: '내집홍보'),
      ],
      // currentIndex는 '홈(0)'으로 설정하여 홈 탭의 연장선상에 있음을 보여줍니다.
      currentIndex: 0,
      selectedItemColor: Colors.deepPurple.shade400,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }
}