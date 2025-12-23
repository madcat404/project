import 'package:flutter/material.dart';

enum DepositStatus { none, imminent, returned, partiallyReturned }

class Unit {
  final String id;
  final String roomNumber, tenantName, expiryDate, deposit, rent, gender, contact, notes, unpaidAmount;
  // [수정] 부동산 이름(realty)과 연락처(realtyPhone) 분리
  final String realty;
  final String realtyPhone; // [추가]

  final String contractDate, area, moveInDate, entrancePassword, roomPassword;
  final bool isVacant;
  final bool hasAc, hasFridge, hasGasStove, hasWasher, hasTv, hasInternet, hasParking, hasElevator;
  final DepositStatus depositStatus;

  const Unit({
    required this.id,
    required this.roomNumber,
    required this.tenantName,
    required this.isVacant,
    required this.expiryDate,
    required this.deposit,
    required this.rent,
    required this.gender,
    required this.contact,
    required this.realty,
    required this.realtyPhone, // [추가]
    required this.notes,
    required this.contractDate,
    required this.unpaidAmount,
    required this.area,
    required this.moveInDate,
    required this.entrancePassword,
    required this.roomPassword,
    required this.hasAc,
    required this.hasFridge,
    required this.hasGasStove,
    required this.hasWasher,
    required this.hasTv,
    required this.hasInternet,
    required this.hasParking,
    required this.hasElevator,
    required this.depositStatus,
  });
}

class Building {
  final String id;
  final String name, address;
  final int totalUnits, vacantUnits;
  final List<Unit> units;

  const Building({
    required this.id,
    required this.name,
    required this.address,
    required this.totalUnits,
    required this.vacantUnits,
    required this.units
  });
}