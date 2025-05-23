import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/utils.dart';

class TaskModel {
  final String id;
  final String uid;
  final String title;
  final Color color;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime dueAt;
  final int isSynced;
  final TimeOfDay dueTime;

  //final int isSynced;
  TaskModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.dueAt,
    required this.color,
    required this.isSynced,
    required this.dueTime,
  });

  TaskModel copyWith({
    String? id,
    String? uid,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueAt,
    Color? color,
    int? isSynced,
    TimeOfDay? dueTime,
  }) {
    return TaskModel(
      dueTime: dueTime ?? this.dueTime,
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueAt: dueAt ?? this.dueAt,
      color: color ?? this.color,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'uid': uid,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dueAt': dueAt.toIso8601String(),
      'hexColor': rgbToHex(color),
      'isSynced': isSynced, //
      'dueTime': DateTime(
        dueAt.year,
        dueAt.month,
        dueAt.day,
        dueTime.hour,
        dueTime.minute,
      ).toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    final dueTimeParsed = DateTime.parse(map['dueTime'] as String);
    return TaskModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      dueAt: DateTime.parse(map['dueAt']),
      color: hexToRgb(map['hexColor']),
      isSynced: map['isSynced'] ?? 1,
      dueTime: TimeOfDay.fromDateTime(dueTimeParsed),
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TaskModel(id: $id, uid: $uid, title: $title, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, dueAt: $dueAt, color: $color, dueTime: $dueTime)';
  }

  @override
  bool operator ==(covariant TaskModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.uid == uid &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.dueAt == dueAt &&
        other.color == color &&
        other.dueTime == dueTime &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uid.hashCode ^
        title.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        dueAt.hashCode ^
        color.hashCode ^
        isSynced.hashCode ^
        dueTime.hashCode;
  }
}
