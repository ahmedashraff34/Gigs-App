/// event_task_request.dart
/// ----------------------
/// Model for sending event task deletion requests to the backend.
/// Only includes the required fields for event task deletion.

class EventTaskRequest {
  final String title;
  final String description;
  final String type;
  final String taskType;
  final int taskPoster;
  final double longitude;
  final double latitude;
  final String location;
  final double fixedPay;
  final int requiredPeople;
  final String startDate;
  final String endDate;
  final int numberOfDays;

  EventTaskRequest({
    required this.title,
    required this.description,
    required this.type,
    required this.taskType,
    required this.taskPoster,
    required this.longitude,
    required this.latitude,
    required this.location,
    required this.fixedPay,
    required this.requiredPeople,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
  })  : assert(location.isNotEmpty, 'location must not be empty'),
        assert(fixedPay > 0, 'fixedPay must be greater than zero'),
        assert(startDate.isNotEmpty, 'startDate must not be empty'),
        assert(endDate.isNotEmpty, 'endDate must not be empty');

  /// Converts this request to a JSON map for backend API.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'task_type': taskType,
      'taskPoster': taskPoster,
      'longitude': longitude,
      'latitude': latitude,
      'location': location,
      'fixedPay': fixedPay,
      'requiredPeople': requiredPeople,
      'startDate': startDate,
      'endDate': endDate,
      'numberOfDays': numberOfDays,
    };
  }
} 