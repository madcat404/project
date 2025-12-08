// 파일 경로: lib/screens/asset_status_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project/services/ocr_service.dart' if (dart.library.html) 'package:project/services/ocr_service_web.dart';
import 'package:project/screens/file_manager_screen.dart';
import 'package:project/screens/home_page.dart';
import 'package:project/models/asset_models.dart';
import 'package:project/services/asset_service.dart';
import 'package:project/widgets/asset_building_selector.dart';
import 'package:project/widgets/asset_unit_card.dart';

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
  bool _isLandscape = false;

  // 데이터 로딩 상태 관리 변수들
  List<Building> _buildings = [];
  bool _isLoading = true; // 로딩 중 여부

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadBuildings(); // 데이터 불러오기 시작
  }

  // 비동기로 데이터 불러오기
  Future<void> _loadBuildings() async {
    try {
      // 서비스에서 데이터를 가져옴 (더미 + 서버)
      final buildings = await _assetService.getBuildings();

      if (!mounted) return;
      setState(() {
        _buildings = buildings;
        _isLoading = false; // 로딩 완료

        // 데이터 로드 후 특정 건물로 이동해야 하는 경우 처리
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
      // 에러 처리
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('데이터를 불러오는데 실패했습니다: $e')));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _scrollToIndex(int index) {
    const double itemWidth = 200.0;
    const double spacing = 12.0;
    final double scrollPosition = index * (itemWidth + spacing);
    _scrollController.animateTo(scrollPosition, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _addAssetFromPdf() async {
    Navigator.pop(context);

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('파일 선택이 취소되었습니다.')));
      return;
    }

    if (!mounted) return;
    _showLoading();

    try {
      final fileBytes = result.files.single.bytes;
      final fileName = result.files.single.name;

      if (fileBytes == null) throw Exception('파일을 읽을 수 없습니다.');

      final responseBody = await _assetService.uploadPdf(fileBytes, fileName);

      if (!mounted) return;
      Navigator.pop(context);

      // 업로드 성공 후 데이터 새로고침 (새로 추가된 건물을 보기 위해)
      await _loadBuildings();

      _showAlert('업로드 완료', '서버 응답: $responseBody');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showAlert('오류', '파일 업로드 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _addAssetFromOcr() async {
    Navigator.pop(context);
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이미지 선택이 취소되었습니다.')));
      return;
    }

    if (!mounted) return;
    _showLoading();

    String ocrResult = await OcrService.performOcr(image.path);

    if (!mounted) return;
    Navigator.pop(context);

    _showAlert('OCR 인식 결과', ocrResult.isEmpty ? '인식된 텍스트가 없습니다.' : ocrResult);
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showAlert(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [TextButton(child: const Text('확인'), onPressed: () => Navigator.of(context).pop())],
      ),
    );
  }

  void _showAssetMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(children: <Widget>[
            ListTile(leading: const Icon(Icons.folder_copy_outlined), title: const Text('파일 관리'), onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FileManagerScreen()));
            }),
            ListTile(leading: const Icon(Icons.add_business_outlined), title: const Text('자산추가'), onTap: _addAssetFromOcr),
            ListTile(leading: const Icon(Icons.picture_as_pdf_outlined), title: const Text('자산추가 (pdf)'), onTap: _addAssetFromPdf),
            ListTile(leading: const Icon(Icons.person_add_alt_1_outlined), title: const Text('임차인등록'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('자산수정'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.edit_note_outlined), title: const Text('임대인수정'), onTap: () => Navigator.pop(context)),
          ]),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(initialIndex: index)),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중이면 로딩 표시
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 건물이 하나도 없을 때 처리
    if (_buildings.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('장부관리')),
        body: const Center(child: Text("등록된 건물이 없습니다.")),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }

    // 인덱스 안전장치
    if (_selectedBuildingIndex >= _buildings.length) {
      _selectedBuildingIndex = 0;
    }

    final selectedBuilding = _buildings[_selectedBuildingIndex];
    final textScaleFactor = _isLandscape ? 1.2 : 1.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.buildingName == null ? '장부관리' : '장부관리 (${widget.buildingName!})', style: TextStyle(fontSize: 18 * textScaleFactor)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.screen_rotation),
            tooltip: '가로로 보기',
            onPressed: () {
              setState(() {
                _isLandscape = !_isLandscape;
                if (_isLandscape) {
                  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
                } else {
                  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                }
              });
            },
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: _showAssetMoreOptions, tooltip: '더보기'),
        ],
      ),
      backgroundColor: Colors.grey[100],
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
                isLandscape: _isLandscape,
                onSelected: (index) {
                  setState(() {
                    _selectedBuildingIndex = index;
                    _scrollToIndex(index);
                  });
                },
              ),
              const SizedBox(height: 24),
            ],
            Text('${selectedBuilding.name} - 호실 현황 (${selectedBuilding.units.length}개)', style: TextStyle(fontSize: 18 * textScaleFactor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // 호실이 없을 경우 안내 메시지
            if (selectedBuilding.units.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(child: Text("등록된 호실 정보가 없습니다.", style: TextStyle(color: Colors.grey[600]))),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedBuilding.units.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return AssetUnitCard(
                    unit: selectedBuilding.units[index],
                    building: selectedBuilding,
                    isLandscape: _isLandscape,
                    allBuildings: _buildings,
                  );
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: '캐쉬'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: '상품'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: '커뮤니티'),
        BottomNavigationBarItem(icon: Icon(Icons.campaign), label: '내집홍보'),
      ],
      currentIndex: 0,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }
}