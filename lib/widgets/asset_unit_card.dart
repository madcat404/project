// 파일 경로: lib/widgets/asset_unit_card.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:project/models/asset_models.dart';
import 'package:project/screens/unit_detail_screen.dart';
import 'package:project/screens/annual_rent_summary_screen.dart';
import 'package:project/screens/deposit_return_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AssetUnitCard extends StatelessWidget {
  final Unit unit;
  final Building building;
  final bool isLandscape;
  final List<Building> allBuildings;

  const AssetUnitCard({
    super.key,
    required this.unit,
    required this.building,
    required this.isLandscape,
    required this.allBuildings,
  });

  @override
  Widget build(BuildContext context) {
    final double textScaleFactor = isLandscape ? 1.2 : 1.0;
    final statusColor = unit.isVacant ? Colors.red : Colors.green;

    IconData genderIcon;
    Color? genderColor;
    if (unit.gender == '남성') {
      genderIcon = Icons.male;
      genderColor = Colors.blueAccent;
    } else if (unit.gender == '여성') {
      genderIcon = Icons.female;
      genderColor = Colors.pinkAccent;
    } else {
      genderIcon = Icons.person_outline;
    }

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unit.roomNumber, style: TextStyle(fontSize: 20 * textScaleFactor, fontWeight: FontWeight.bold, color: statusColor)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconButton(context, Icons.info_outline, '상세보기', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UnitDetailScreen(unit: unit, building: building)));
                    }, textScaleFactor),
                    _buildIconButton(context, Icons.campaign, '부동산에 공실 알림', () => _showRealEstateNotificationDialog(context), textScaleFactor),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
              children: [
                TableRow(children: [
                  _buildInfoCell(genderIcon, unit.tenantName, textScaleFactor, color: genderColor),
                  _buildClickableInfoCell(Icons.phone_iphone_outlined, unit.contact, () => _makePhoneCall(context, unit.contact), textScaleFactor),
                ]),
                TableRow(children: [
                  _buildInfoCell(Icons.event_available_outlined, unit.moveInDate, textScaleFactor),
                  _buildInfoCell(Icons.date_range_outlined, unit.expiryDate, textScaleFactor),
                ]),
                TableRow(children: [
                  _buildClickableDepositCell(context, textScaleFactor),
                  _buildInfoCell(Icons.square_foot_outlined, unit.area, textScaleFactor),
                ]),
                TableRow(children: [
                  _buildInfoCell(Icons.sensor_door_outlined, unit.roomPassword, textScaleFactor),
                  _buildInfoCell(Icons.vpn_key_outlined, unit.entrancePassword, textScaleFactor),
                ]),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: [
                _buildAmenityIcon(Icons.ac_unit, unit.hasAc, '에어컨', textScaleFactor),
                _buildAmenityIcon(Icons.kitchen, unit.hasFridge, '냉장고', textScaleFactor),
                _buildAmenityIcon(Icons.local_fire_department, unit.hasGasStove, '가스레인지', textScaleFactor),
                _buildAmenityIcon(Icons.local_laundry_service, unit.hasWasher, '세탁기', textScaleFactor),
                _buildAmenityIcon(Icons.tv, unit.hasTv, 'TV', textScaleFactor),
                _buildAmenityIcon(Icons.wifi, unit.hasInternet, '인터넷', textScaleFactor),
                _buildAmenityIcon(Icons.local_parking, unit.hasParking, '주차장', textScaleFactor),
                _buildAmenityIcon(Icons.elevator, unit.hasElevator, '엘리베이터', textScaleFactor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, String tooltip, VoidCallback onPressed, double scale) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      child: Material(
        type: MaterialType.transparency,
        child: IconButton(icon: Icon(icon, size: 20 * scale), visualDensity: VisualDensity.compact, tooltip: tooltip, onPressed: onPressed),
      ),
    );
  }

  Widget _buildInfoCell(IconData icon, String text, double scale, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16 * scale, color: color ?? Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13 * scale), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildClickableInfoCell(IconData icon, String text, VoidCallback onTap, double scale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: (text.isNotEmpty && text != '-') ? onTap : null,
        child: Row(
          children: [
            Icon(icon, size: 16 * scale, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: TextStyle(color: (text.isNotEmpty && text != '-') ? Colors.blue : Colors.black, decoration: (text.isNotEmpty && text != '-') ? TextDecoration.underline : TextDecoration.none, fontSize: 13 * scale), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableDepositCell(BuildContext context, double scale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.attach_money_outlined, size: 16 * scale, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 13 * scale, color: Colors.black),
                children: [
                  TextSpan(
                    text: '${unit.deposit} ',
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => DepositReturnScreen(buildings: allBuildings))),
                  ),
                  const TextSpan(text: '/ '),
                  TextSpan(
                    text: unit.rent,
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => AnnualRentSummaryScreen(unit: unit, building: building))),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityIcon(IconData icon, bool isAvailable, String name, double scale) {
    return Tooltip(
      message: name,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Icon(icon, size: 20 * scale, color: isAvailable ? Colors.grey[700] : Colors.grey[300]),
      ),
    );
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('전화 앱을 열 수 없습니다: $phoneNumber')));
      }
    }
  }

  void _showRealEstateNotificationDialog(BuildContext context) {
    final List<String> realEstateAgencies = allBuildings.expand((b) => b.units).map((u) => u.realty).where((r) => r.isNotEmpty && r != '-').toSet().toList();
    final Set<String> selectedAgencies = {};

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${unit.roomNumber} 공실 알림'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: realEstateAgencies.length,
                  itemBuilder: (context, index) {
                    final agency = realEstateAgencies[index];
                    return CheckboxListTile(
                      title: Text(agency),
                      value: selectedAgencies.contains(agency),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) selectedAgencies.add(agency);
                          else selectedAgencies.remove(agency);
                        });
                      },
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(child: const Text('취소'), onPressed: () => Navigator.of(context).pop()),
                TextButton(
                  child: const Text('보내기'),
                  onPressed: selectedAgencies.isEmpty ? null : () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${selectedAgencies.length}곳의 부동산에 알림을 보냈습니다.'), duration: const Duration(seconds: 2)));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}