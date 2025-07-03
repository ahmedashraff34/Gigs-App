/// offer.dart
/// ----------
/// Data model for offers made by runners on tasks. Used for offer creation, display, and status tracking.
/// Fields: (list all fields here for clarity).
///
/// Suggestions:
/// - Keep this model simple and focused on offer data.
/// - Document any mapping to/from backend or related models.

enum OfferStatus {
  PENDING,
  AWAITING_PAYMENT,
  CANCELLED,
  ACCEPTED
}

class Offer {
  final String id;
  final String runnerId;
  final double amount;
  final String message;
  final DateTime timestamp;
  final String? taskId;
  final OfferStatus status;

  Offer({
    required this.id,
    required this.runnerId,
    required this.amount,
    required this.message,
    required this.timestamp,
    this.taskId,
    this.status = OfferStatus.PENDING,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    String id = json['id']?.toString() ?? json['offerId']?.toString() ?? '';
    String runnerId = json['runnerId']?.toString() ?? '';
    double amount = (json['amount'] as num?)?.toDouble() ?? 0.0;
    String message = json['comment'] ?? json['message'] ?? '';
    DateTime timestamp;
    try {
      timestamp = json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now();
    } catch (_) {
      timestamp = DateTime.now();
    }
    String? taskId = json['taskId']?.toString() ?? json['task_id']?.toString();
    
    // Parse status from JSON
    OfferStatus status = OfferStatus.PENDING; // Default to PENDING
    if (json['status'] != null) {
      try {
        status = OfferStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'].toString().toUpperCase(),
          orElse: () => OfferStatus.PENDING,
        );
      } catch (_) {
        status = OfferStatus.PENDING;
      }
    }
    
    return Offer(
      id: id,
      runnerId: runnerId,
      amount: amount,
      message: message,
      timestamp: timestamp,
      taskId: taskId,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'runnerId': runnerId,
      'amount': amount,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'taskId': taskId,
      'status': status.toString().split('.').last,
    };
  }
} 