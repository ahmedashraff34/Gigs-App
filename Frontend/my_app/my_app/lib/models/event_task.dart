/// event_task.dart
/// --------------
/// Data model for event staffing tasks. Used for posting and displaying event-specific fields.
///
/// This model is focused on event-specific data. For unified task handling, consider using a base Task model and extending it for event tasks.
///
/// Usage:
///   - Used for creating, serializing, and displaying event staffing tasks.
///   - Maps to/from backend event task objects.
///
/// See also: EventTaskCard (UI widget for displaying this model)
/// Fields: taskId, taskPoster, title, description, type, taskType, longitude, latitude, createdDate, additionalRequirements, status, location, fixedPay, requiredPeople, runnerIds, startDate, endDate, numberOfDays.
///
/// Suggestions:
/// - Move any business logic (e.g., validation) out of the model.
/// - Document any mapping to/from backend or TaskResponse.
import 'package:flutter/material.dart';

/// Data model for event staffing tasks.
class EventTask {
  final int? taskId;
  final int taskPoster;
  final String title;
  final String description;
  final String type;
  final String taskType;
  final double longitude;
  final double latitude;
  final String? createdDate;
  final Map<String, dynamic>? additionalRequirements;
  final String? status;
  final String location;
  final double fixedPay;
  final int requiredPeople;
  final List<dynamic>? runnerIds;
  final String startDate;
  final String endDate;
  final int numberOfDays;

  EventTask({
    this.taskId,
    required this.taskPoster,
    required this.title,
    required this.description,
    required this.type,
    required this.taskType,
    required this.longitude,
    required this.latitude,
    this.createdDate,
    this.additionalRequirements,
    this.status,
    required this.location,
    required this.fixedPay,
    required this.requiredPeople,
    this.runnerIds,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
  })  : assert(location.isNotEmpty, 'location must not be empty'),
        assert(fixedPay > 0, 'fixedPay must be greater than zero'),
        assert(startDate.isNotEmpty, 'startDate must not be empty'),
        assert(endDate.isNotEmpty, 'endDate must not be empty');

  /// Creates an EventTask from a JSON map (e.g., from backend response).
  factory EventTask.fromJson(Map<String, dynamic> json) {
    return EventTask(
      taskId: json['taskId'] as int?,
      taskPoster: json['taskPoster'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      taskType: json['task_type'] as String,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : 0.0,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : 0.0,
      createdDate: json['createdDate'] as String?,
      additionalRequirements: json['additionalRequirements'] as Map<String, dynamic>?,
      status: json['status'] as String?,
      location: json['location'] as String? ?? '',
      fixedPay: json['fixedPay'] != null ? (json['fixedPay'] as num).toDouble() : 0.0,
      requiredPeople: json['requiredPeople'] != null ? json['requiredPeople'] as int : 0,
      runnerIds: json['runnerIds'] != null ? List<dynamic>.from(json['runnerIds']) : [],
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      numberOfDays: json['numberOfDays'] != null ? json['numberOfDays'] as int : 0,
    );
  }

  /// Converts this EventTask to a JSON map (e.g., for sending to backend).
  /// Only includes non-null fields and omits irrelevant fields for event tasks.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'taskId': taskId,
      'taskPoster': taskPoster,
      'title': title,
      'description': description,
      'type': type,
      'task_type': taskType,
      'longitude': longitude,
      'latitude': latitude,
      'createdDate': createdDate,
      'additionalRequirements': additionalRequirements,
      'status': status,
      'location': location,
      'fixedPay': fixedPay,
      'requiredPeople': requiredPeople,
      'runnerIds': runnerIds,
      'startDate': startDate,
      'endDate': endDate,
      'numberOfDays': numberOfDays,
    };
    // Remove nulls
    map.removeWhere((key, value) => value == null);
    return map;
  }
}
