// lib/models/task_model.dart
import 'dart:convert';
import 'dart:io';

/// Defines input types for schema-driven form rendering
enum InputType { text, number, boolean, date }

/// Metadata for each attribute field
class AttrSchema {
  final String key;
  final String label;
  final InputType type;

  const AttrSchema(this.key, this.label, this.type);
}

/// Task types
enum TaskType { REGULAR, EVENT }

/// Categories for tasks
enum Category {
  Cleaning,
  Delivery,
  Assembly,
  Handyman,
  Custom,
  Lifting,
  EVENT_STAFFING
}

/// Schemas: predefined attributes for each Regular category
const Map<Category, List<AttrSchema>> regularSchemas = {
  Category.Cleaning: [
    AttrSchema('rooms', 'Rooms', InputType.number),
    AttrSchema('bathrooms', 'Bathrooms', InputType.number),
    AttrSchema('cleaningType', 'Cleaning Type', InputType.text),
    AttrSchema('suppliesProvided', 'Supplies Provided', InputType.boolean),
  ],
  Category.Delivery: [
    AttrSchema('pickupLocation', 'Pickup Location', InputType.text),
    AttrSchema('dropoffLocation', 'Dropoff Location', InputType.text),
    AttrSchema('numberOfItems', 'Number of Items', InputType.number),
    AttrSchema('itemType', 'Item Type', InputType.text),
    AttrSchema('fragile', 'Fragile', InputType.boolean),
  ],
  Category.Assembly: [
    AttrSchema('furnitureType', 'Furniture Type', InputType.text),
    AttrSchema(
        'instructionsAvailable', 'Instructions Available', InputType.boolean),
    AttrSchema('toolsRequired', 'Tools Required', InputType.text),
    AttrSchema('estimatedTime', 'Estimated Time (min)', InputType.number),
  ],
  Category.Handyman: [
    AttrSchema('issueType', 'Issue Type', InputType.text),
    AttrSchema('toolsRequired', 'Tools Required', InputType.boolean),
    AttrSchema('materialsProvided', 'Materials Provided', InputType.boolean),
    AttrSchema('locationInHouse', 'Location in House', InputType.text),
  ],
  Category.Custom: [
    AttrSchema('description', 'Task Description', InputType.text),
    AttrSchema('durationEstimate', 'Duration (min)', InputType.number),
    AttrSchema('toolsRequired', 'Tools Required', InputType.text),
  ],
  Category.Lifting: [
    AttrSchema('weightEstimateKg', 'Weight Estimate (kg)', InputType.number),
    AttrSchema('numberOfItems', 'Number of Items', InputType.number),
    AttrSchema('hasElevator', 'Elevator Available', InputType.boolean),
    AttrSchema('floorNumber', 'Origin Floor', InputType.number),
    AttrSchema('destinationFloor', 'Destination Floor', InputType.number),
  ],
};

/// Model used for posting Regular tasks
class RegularTask {
  final TaskType taskType = TaskType.REGULAR;
  final Category category;
  final int taskPoster;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final double amount;
  final Map<String, dynamic>? additionalRequirements;
  final Map<String, dynamic>? additionalAttributes;
  final List<String> imageUrls;

  RegularTask({
    required this.category,
    required this.taskPoster,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.amount,
    Map<String, dynamic>? additionalRequirements,
    Map<String, dynamic>? additionalAttributes,
    required this.imageUrls,
  })  : additionalRequirements = additionalRequirements ?? {},
        additionalAttributes =
            additionalAttributes ?? _initAttributes(category);

  /// Initialize default attributes for a RegularTask based on category
  static Map<String, dynamic> _initAttributes(Category cat) {
    final schema = regularSchemas[cat] ?? [];
    return {for (var field in schema) field.key: null};
  }

  Map<String, dynamic> toJson() {
    return {
      'task_type': taskType.name,
      'type': category.name,
      'taskPoster': taskPoster,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'amount': amount,
      'additionalRequirements': additionalRequirements,
      'additionalAttributes': additionalAttributes,
      'imageUrls': imageUrls,
    };
  }
}

/// Model used for posting Event Staffing tasks
class EventStaffingTask {
  final TaskType taskType = TaskType.EVENT;
  final Category category = Category.EVENT_STAFFING;
  final int taskPoster;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> additionalRequirements;
  final double fixedPay;
  final int requiredPeople;
  final String location;
  final String? startDate;
  final String? endDate;
  final int? numberOfDays;
  final List<String> imageUrls;

  EventStaffingTask({
    required this.taskPoster,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.additionalRequirements,
    required this.fixedPay,
    required this.requiredPeople,
    required this.location,
    this.startDate,
    this.endDate,
    this.numberOfDays,
    required this.imageUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'task_type': taskType.name,
      'type': category.name,
      'taskPoster': taskPoster,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'additionalRequirements': additionalRequirements,
      'fixedPay': fixedPay,
      'requiredPeople': requiredPeople,
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
      'numberOfDays': numberOfDays,
      'imageUrls': imageUrls,
    };
  }
}

class TaskResponse {
  final int taskId;
  final int taskPoster;
  final String title;
  final String description;
  final String createdDate;
  final Category category; // parsed from the JSON "type" field
  final double longitude;
  final double latitude;
  final Map<String, dynamic> additionalRequirements;
  final String status;

  // "Regular" task fields:
  final double? amount;
  final Map<String, dynamic>? additionalAttributes;

  // "Event" task fields:
  final double? fixedPay;
  final int? requiredPeople;
  final String? location;
  final String? startDate; // ISO-string e.g. "2025-07-10"
  final String? endDate; // ISO-string e.g. "2025-07-12"
  final int? numberOfDays;

  // Common response fields:
  final int? runnerId;
  final List<int>? runnerIds;
  final List<String>? imageUrls;

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
    this.amount,
    this.additionalAttributes,
    this.fixedPay,
    this.requiredPeople,
    this.location,
    this.startDate,
    this.endDate,
    this.numberOfDays,
    this.runnerId,
    this.runnerIds,
    this.imageUrls,
    required this.createdDate,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    List<int>? parseIntList(dynamic value) {
      if (value is List) return value.whereType<int>().toList();
      return null;
    }

    return TaskResponse(
      taskId: json['taskId'],
      taskPoster: json['taskPoster'],
      title: json['title'],
      description: json['description'],
      category: Category.values.firstWhere(
        (e) => e.name.toLowerCase() == json['type'].toString().toLowerCase(),
        orElse: () => Category.Custom,
      ),
      longitude: parseDouble(json['longitude']),
      latitude: parseDouble(json['latitude']),
      additionalRequirements:
          Map<String, dynamic>.from(json['additionalRequirements'] ?? {}),
      status: json['status'],
      amount: parseDouble(json['amount']),
      additionalAttributes:
          Map<String, dynamic>.from(json['additionalAttributes'] ?? {}),
      runnerId: json['runnerId'],
      createdDate: json['createdDate'],
      fixedPay: json['fixedPay'] != null ? parseDouble(json['fixedPay']) : null,
      requiredPeople: json['requiredPeople'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      numberOfDays: json['numberOfDays'],
      runnerIds: parseIntList(json['runnerIds']),
      location: json['location'],
      imageUrls:
          (json['imageUrls'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'taskPoster': taskPoster,
        'title': title,
        'description': description,
        'createdDate': createdDate,
        'type': category.name,
        'longitude': longitude,
        'latitude': latitude,
        'additionalRequirements': additionalRequirements,
        'status': status,
        if (amount != null) 'amount': amount,
        if (additionalAttributes != null)
          'additionalAttributes': additionalAttributes,
        if (fixedPay != null) 'fixedPay': fixedPay,
        if (requiredPeople != null) 'requiredPeople': requiredPeople,
        if (location != null) 'location': location,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (numberOfDays != null) 'numberOfDays': numberOfDays,
        if (runnerId != null) 'runnerId': runnerId,
        if (runnerIds != null) 'runnerIds': runnerIds,
      };
}

class TaskImage {
  final File file;
  final String url;
  TaskImage(this.file, this.url);
}

final List<TaskImage> _taskImages = [];
