import 'package:flutter/material.dart';

enum DepositStatus { imminent, returned, partiallyReturned }

class Unit {
  // [수정] DB의 'no' 컬럼에 해당하는 id 필드 추가
  final String id;
  final String roomNumber, tenantName, expiryDate, deposit, rent, gender, contact, realty, notes, unpaidAmount;
  // [추가] 부동산 연락처 필드 추가 (PHP 스크립트 대응)
  final String realtorPhone;
  final String contractDate, area, moveInDate, entrancePassword, roomPassword;
  final bool isVacant;
  final bool hasAc, hasFridge, hasGasStove, hasWasher, hasTv, hasInternet, hasParking, hasElevator;
  final DepositStatus depositStatus;

  const Unit({
    required this.id, // 필수값으로 변경
    required this.roomNumber, required this.tenantName, required this.isVacant,
    required this.expiryDate, required this.deposit, required this.rent,
    required this.gender, required this.contact, required this.realty,
    this.realtorPhone = '', // 기본값 설정
    required this.notes, required this.contractDate, required this.unpaidAmount,
    required this.area, required this.moveInDate, required this.entrancePassword, required this.roomPassword,
    required this.hasAc, required this.hasFridge, required this.hasGasStove, required this.hasWasher,
    required this.hasTv, required this.hasInternet, required this.hasParking, required this.hasElevator,
    required this.depositStatus,
  });

  // [추가] 데이터를 JSON으로 변환하는 메서드 (PHP로 보낼 때 사용)
  Map<String, dynamic> toJson() {
    return {
      'no': id, // PHP에서 $_POST['no']로 받음
      'tenant_name': tenantName,
      'contact': contact,
      'expiry_date': expiryDate,
      'deposit': deposit,
      'rent': rent,
      'area': area,
      'move_in_date': moveInDate,
      'entrance_pw': entrancePassword,
      'room_pw': roomPassword,
      'gender': gender,
      'realty': realty,
      'realtor_phone': realtorPhone,
      'notes': notes,
      // 필요한 다른 필드들도 여기에 추가하면 PHP에서 받아서 처리 가능
    };
  }
}

class Building {
  final String name, address;
  final int totalUnits, vacantUnits;
  final List<Unit> units;
  const Building({ required this.name, required this.address, required this.totalUnits, required this.vacantUnits, required this.units });
}