import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/models/asset_models.dart';
import 'package:project/services/asset_service.dart';

class UnitDetailScreen extends StatefulWidget {
  final Unit unit;
  final Building building;

  const UnitDetailScreen({super.key, required this.unit, required this.building});

  @override
  State<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> {
  final AssetService _assetService = AssetService();
  bool _isEditing = false;
  bool _isSaving = false;

  // [추가] 데이터가 수정되었는지 여부를 추적하는 변수
  bool _dataChanged = false;

  late TextEditingController _tenantNameController;
  late TextEditingController _contactController;
  late TextEditingController _expiryDateController;
  late TextEditingController _depositController;
  late TextEditingController _rentController;
  late TextEditingController _areaController;
  late TextEditingController _moveInDateController;
  late TextEditingController _entrancePwController;
  late TextEditingController _roomPwController;
  late TextEditingController _genderController;
  late TextEditingController _realtyController;
  late TextEditingController _realtyPhoneController;
  late TextEditingController _notesController;

  late bool _hasAc, _hasFridge, _hasGasStove, _hasWasher, _hasTv, _hasInternet, _hasParking, _hasElevator;
  late Unit _currentUnit;

  @override
  void initState() {
    super.initState();
    _currentUnit = widget.unit;
    _initializeControllers();
  }

  void _initializeControllers() {
    _tenantNameController = TextEditingController(text: _currentUnit.tenantName);
    _contactController = TextEditingController(text: _currentUnit.contact);
    _expiryDateController = TextEditingController(text: _currentUnit.expiryDate);

    _depositController = TextEditingController(text: _formatWithCommas(_currentUnit.deposit));
    _rentController = TextEditingController(text: _formatWithCommas(_currentUnit.rent));

    _areaController = TextEditingController(text: _currentUnit.area);
    _moveInDateController = TextEditingController(text: _currentUnit.moveInDate);
    _entrancePwController = TextEditingController(text: _currentUnit.entrancePassword);
    _roomPwController = TextEditingController(text: _currentUnit.roomPassword);
    _genderController = TextEditingController(text: _currentUnit.gender);
    _realtyController = TextEditingController(text: _currentUnit.realty);
    _realtyPhoneController = TextEditingController(text: _currentUnit.realtyPhone);
    _notesController = TextEditingController(text: _currentUnit.notes);

    _hasAc = _currentUnit.hasAc;
    _hasFridge = _currentUnit.hasFridge;
    _hasGasStove = _currentUnit.hasGasStove;
    _hasWasher = _currentUnit.hasWasher;
    _hasTv = _currentUnit.hasTv;
    _hasInternet = _currentUnit.hasInternet;
    _hasParking = _currentUnit.hasParking;
    _hasElevator = _currentUnit.hasElevator;
  }

  String _formatWithCommas(String value) {
    if (value.isEmpty || value == '-') return value;
    String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.isEmpty) return value;

    try {
      final number = int.parse(cleanValue);
      return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    } catch (e) {
      return value;
    }
  }

  @override
  void dispose() {
    _tenantNameController.dispose();
    _contactController.dispose();
    _expiryDateController.dispose();
    _depositController.dispose();
    _rentController.dispose();
    _areaController.dispose();
    _moveInDateController.dispose();
    _entrancePwController.dispose();
    _roomPwController.dispose();
    _genderController.dispose();
    _realtyController.dispose();
    _realtyPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_currentUnit.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('오류: ID가 없는 호실은 수정할 수 없습니다.')));
      return;
    }

    setState(() => _isSaving = true);

    final updatedUnit = Unit(
      id: _currentUnit.id,
      roomNumber: _currentUnit.roomNumber,
      tenantName: _tenantNameController.text,
      isVacant: _tenantNameController.text == '-' || _tenantNameController.text.isEmpty,
      expiryDate: _expiryDateController.text,
      deposit: _depositController.text,
      rent: _rentController.text,
      gender: _genderController.text,
      contact: _contactController.text,
      realty: _realtyController.text,
      realtyPhone: _realtyPhoneController.text,
      notes: _notesController.text,
      contractDate: _currentUnit.contractDate,
      unpaidAmount: _currentUnit.unpaidAmount,
      area: _areaController.text,
      moveInDate: _moveInDateController.text,
      entrancePassword: _entrancePwController.text,
      roomPassword: _roomPwController.text,
      hasAc: _hasAc,
      hasFridge: _hasFridge,
      hasGasStove: _hasGasStove,
      hasWasher: _hasWasher,
      hasTv: _hasTv,
      hasInternet: _hasInternet,
      hasParking: _hasParking,
      hasElevator: _hasElevator,
      depositStatus: _currentUnit.depositStatus,
    );

    bool success = await _assetService.updateUnit(updatedUnit);

    setState(() => _isSaving = false);

    if (success) {
      // [수정] 저장이 성공하면 변경 여부를 true로 설정
      _dataChanged = true;

      setState(() {
        _currentUnit = updatedUnit;
        _isEditing = false;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('성공적으로 저장되었습니다.')));
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('저장에 실패했습니다. 잠시 후 다시 시도해주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // [수정] WillPopScope로 감싸서 뒤로가기 시 변경 여부(_dataChanged)를 전달
    return WillPopScope(
      onWillPop: () async {
        // 여기서 true/false를 넘겨주면 이전 화면의 await Navigator.push(...)가 이 값을 받습니다.
        Navigator.pop(context, _dataChanged);
        return false; // 시스템 기본 뒤로가기는 막고 위에서 직접 pop 합니다.
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.building.name} - ${_currentUnit.roomNumber}'),
          actions: [
            if (_isSaving)
              const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue)))
            else
              IconButton(
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                onPressed: () {
                  if (_isEditing) {
                    _saveChanges();
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              _buildDetailRow('임차인', _tenantNameController),
              _buildDetailRow('성별', _genderController),
              _buildDetailRow('연락처', _contactController, keyboardType: TextInputType.phone),
              _buildDetailRow('입주일', _moveInDateController, keyboardType: TextInputType.datetime),
              _buildDetailRow('만료일', _expiryDateController, keyboardType: TextInputType.datetime),
              _buildDetailRow(
                  '보증금',
                  _depositController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()]
              ),
              _buildDetailRow(
                  '월세',
                  _rentController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()]
              ),
              _buildDetailRow('현관 비밀번호', _entrancePwController),
              _buildDetailRow('방 비밀번호', _roomPwController),
              _buildDetailRow('면적', _areaController),

              _buildDetailRow('부동산', _realtyController),
              _buildDetailRow('부동산 연락처', _realtyPhoneController, keyboardType: TextInputType.phone),

              _buildDetailRow('메모', _notesController, maxLines: 3),

              const Divider(height: 32),
              _buildAmenitiesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 100, child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          Expanded(
            child: _isEditing
                ? TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              inputFormatters: inputFormatters,
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                border: OutlineInputBorder(),
              ),
            )
                : Text(controller.text, style: const TextStyle(fontSize: 16), textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('편의시설', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (_isEditing) const Text('(터치하여 변경)', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildAmenityChip('에어컨', _hasAc, (val) => setState(() => _hasAc = val)),
            _buildAmenityChip('냉장고', _hasFridge, (val) => setState(() => _hasFridge = val)),
            _buildAmenityChip('가스레인지', _hasGasStove, (val) => setState(() => _hasGasStove = val)),
            _buildAmenityChip('세탁기', _hasWasher, (val) => setState(() => _hasWasher = val)),
            _buildAmenityChip('TV', _hasTv, (val) => setState(() => _hasTv = val)),
            _buildAmenityChip('인터넷', _hasInternet, (val) => setState(() => _hasInternet = val)),
            _buildAmenityChip('주차장', _hasParking, (val) => setState(() => _hasParking = val)),
            _buildAmenityChip('엘리베이터', _hasElevator, (val) => setState(() => _hasElevator = val)),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenityChip(String name, bool isAvailable, Function(bool) onChanged) {
    return InkWell(
      onTap: _isEditing ? () => onChanged(!isAvailable) : null,
      borderRadius: BorderRadius.circular(20),
      child: Chip(
        avatar: Icon(isAvailable ? Icons.check_circle : Icons.cancel_outlined, color: isAvailable ? Colors.green : (_isEditing ? Colors.red : Colors.grey)),
        label: Text(name),
        backgroundColor: isAvailable ? Colors.green.withOpacity(0.1) : (_isEditing ? Colors.red.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
        side: _isEditing ? BorderSide(color: isAvailable ? Colors.green : Colors.red, width: 1) : BorderSide.none,
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) return newValue;

    final int value = int.parse(newText);
    final String newTextFormatted = value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return newValue.copyWith(
      text: newTextFormatted,
      selection: TextSelection.collapsed(offset: newTextFormatted.length),
    );
  }
}