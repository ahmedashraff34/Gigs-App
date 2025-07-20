// Offer model for backend entity

enum OfferStatus {
  PENDING,
  AWAITING_PAYMENT,
  PAID,
  CANCELLED,
  ACCEPTED,
}

class Offer {
  final int taskId;
  final int runnerId;
  final double amount;
  final String comment;
  OfferStatus? offerStatus;

  Offer({
    required this.taskId,
    required this.runnerId,
    required this.amount,
    required this.comment,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      taskId: json['taskId'],
      runnerId: json['runnerId'],
      amount: (json['amount'] as num).toDouble(),
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'runnerId': runnerId,
      'amount': amount,
      'comment': comment,
    };
  }
}

class OfferResponse {
  final int offerId;
  final int taskId;
  final int runnerId;
  final double amount;
  final String comment;
  final OfferStatus status;

  OfferResponse({
    required this.offerId,
    required this.taskId,
    required this.runnerId,
    required this.amount,
    required this.comment,
    required this.status,
  });

  factory OfferResponse.fromJson(Map<String, dynamic> json) {
    return OfferResponse(
      offerId: json['offerId'],
      taskId: json['taskId'],
      runnerId: json['runnerId'],
      amount: (json['amount'] as num).toDouble(),
      comment: json['comment'] ?? '',
      status: OfferStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'PENDING'),
        orElse: () => OfferStatus.PENDING,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offerId': offerId,
      'taskId': taskId,
      'runnerId': runnerId,
      'amount': amount,
      'comment': comment,
      'status': status.toString().split('.').last,
    };
  }
}
