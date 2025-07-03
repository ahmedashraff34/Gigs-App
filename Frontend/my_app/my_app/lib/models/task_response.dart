/// task_response.dart
/// ------------------
/// Model representing a Task returned from the backend (response).
/// Handles mapping from backend JSON, including category normalization logic.
/// Fields: taskId, taskPoster, title, description, createdDate, category, longitude, latitude, additionalRequirements, status, amount, additionalAttributes, runnerId.
///
/// Suggestions:
/// - Consider moving debug print statements to a logger or removing for production.
/// - Keep category normalization logic well-documented.
/// - If possible, unify with other task models for consistency.
import '../models/task.dart';
import 'question.dart';
import 'offer.dart';
import 'package:flutter/material.dart';

enum Category {
  Cleaning,
  EventStaffing,
  Delivery,
  Handyman,
  Moving,
  Technology,
  Gardening,
  Grocery,
  Event,
  Other,
}

/// Model representing a Task returned from the backend (response)
class TaskResponse {
  final int taskId;
  final int taskPoster;
  final String title;
  final String description;
  final String? createdDate;
  final Category category;
  final double longitude;
  final double latitude;
  final Map<String, dynamic> additionalRequirements;
  final String status;
  final double amount;
  final Map<String, dynamic> additionalAttributes;
  final int? runnerId;
  final String? location;
  final double? fixedPay;
  final int? requiredPeople;
  final String? startDate;
  final String? endDate;
  final int? numberOfDays;

  TaskResponse({
    required this.taskId,
    required this.taskPoster,
    required this.title,
    required this.description,
    required this.category,
    required this.longitude,
    required this.latitude,
    required this.additionalRequirements,
    required this.status,
    required this.amount,
    required this.additionalAttributes,
    required this.runnerId,
    this.createdDate,
    this.location,
    this.fixedPay,
    this.requiredPeople,
    this.startDate,
    this.endDate,
    this.numberOfDays,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String normalizeCategory(String? raw) {
      if (raw == null) return 'Other';
      return raw.replaceAll(' ', '').replaceAll('_', '').toLowerCase();
    }

    // Debug statements for category mapping
    print('[DEBUG] Incoming type: \\${json['type']}');
    for (var e in Category.values) {
      print('[DEBUG] Enum: \\${e.name} | Normalized: \\${normalizeCategory(e.name)}');
    }
    print('[DEBUG] Normalized incoming: \\${normalizeCategory(json['type'])}');

    final matchedCategory = Category.values.firstWhere(
      (e) => normalizeCategory(e.name) == normalizeCategory(json['type']),
      orElse: () => Category.Other,
    );
    print('[DEBUG] Matched category: \\${matchedCategory.name}');

    // Debug statements for each attribute
    print('[DEBUG] createdDate: \\${json['createdDate']} (type: \\${json['createdDate']?.runtimeType})');
    print('[DEBUG] taskId: \\${json['taskId']} (type: \\${json['taskId']?.runtimeType})');
    print('[DEBUG] taskPoster: \\${json['taskPoster']} (type: \\${json['taskPoster']?.runtimeType})');
    print('[DEBUG] title: \\${json['title']} (type: \\${json['title']?.runtimeType})');
    print('[DEBUG] description: \\${json['description']} (type: \\${json['description']?.runtimeType})');
    print('[DEBUG] type: \\${json['type']} (type: \\${json['type']?.runtimeType})');
    print('[DEBUG] longitude: \\${json['longitude']} (type: \\${json['longitude']?.runtimeType})');
    print('[DEBUG] latitude: \\${json['latitude']} (type: \\${json['latitude']?.runtimeType})');
    print('[DEBUG] additionalRequirements: \\${json['additionalRequirements']} (type: \\${json['additionalRequirements']?.runtimeType})');
    print('[DEBUG] status: \\${json['status']} (type: \\${json['status']?.runtimeType})');
    print('[DEBUG] amount: \\${json['amount']} (type: \\${json['amount']?.runtimeType})');
    print('[DEBUG] additionalAttributes: \\${json['additionalAttributes']} (type: \\${json['additionalAttributes']?.runtimeType})');
    print('[DEBUG] runnerId: \\${json['runnerId']} (type: \\${json['runnerId']?.runtimeType})');

    return TaskResponse(
      createdDate: json['createdDate'],
      taskId: parseInt(json['taskId']),
      taskPoster: parseInt(json['taskPoster']),
      title: json['title'],
      description: json['description'],
      category: matchedCategory,
      longitude: parseDouble(json['longitude']),
      latitude: parseDouble(json['latitude']),
      additionalRequirements:
          Map<String, dynamic>.from(json['additionalRequirements'] ?? {}),
      status: json['status'],
      amount: parseDouble(json['amount']),
      additionalAttributes:
          Map<String, dynamic>.from(json['additionalAttributes'] ?? {}),
      runnerId: json['runnerId'] != null ? parseInt(json['runnerId']) : null,
      location: json['location'] as String?,
      fixedPay: json['fixedPay'] != null ? (json['fixedPay'] as num).toDouble() : null,
      requiredPeople: json['requiredPeople'] as int?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      numberOfDays: json['numberOfDays'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'taskPoster': taskPoster,
      'title': title,
      'description': description,
      'type': category.name,
      'longitude': longitude,
      'latitude': latitude,
      'additionalRequirements': additionalRequirements,
      'status': status,
      'amount': amount,
      'additionalAttributes': additionalAttributes,
      'runnerId': runnerId,
      'location': location,
      'fixedPay': fixedPay,
      'requiredPeople': requiredPeople,
      'startDate': startDate,
      'endDate': endDate,
      'numberOfDays': numberOfDays,
    };
  }
} 