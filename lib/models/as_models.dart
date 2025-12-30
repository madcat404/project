// 파일 경로: lib/models/as_models.dart
import 'package:flutter/material.dart';

class AsRequest {
  final String id;
  final String title;
  final String content; // 상세 내용
  final String roomNumber;
  final String status;
  final DateTime date;
  final String author;

  AsRequest({
    required this.id,
    required this.title,
    required this.content,
    required this.roomNumber,
    required this.status,
    required this.date,
    required this.author,
  });

  // PHP JSON 데이터를 Dart 객체로 변환
  factory AsRequest.fromJson(Map<String, dynamic> json) {
    return AsRequest(
      id: json['id'].toString(),
      title: json['title'] ?? '제목 없음',
      content: json['content'] ?? '내용이 없습니다.',
      roomNumber: json['room_number'] ?? '호수 미정',
      status: json['status'] ?? '접수',
      author: json['author'] ?? '익명',
      date: DateTime.parse(json['created_at']),
    );
  }
}