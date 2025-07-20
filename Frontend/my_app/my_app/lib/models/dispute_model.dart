import 'package:flutter/material.dart';

class Dispute {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final String posterId;
  final String runnerId;
  final String posterName;
  final String runnerName;
  final String? resolution;
  final DateTime? resolvedAt;
  final List<String> evidenceUris;

  Dispute({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.posterId,
    required this.runnerId,
    required this.posterName,
    required this.runnerName,
    this.resolution,
    this.resolvedAt,
    this.evidenceUris = const [],
  });

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      id: (json['disputeId'] ?? json['id'] ?? '').toString(),
      title: json['title'] ?? json['reason'] ?? '',
      description: json['description'] ?? '',
      status: (json['status'] ?? '').toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      posterId: (json['raisedBy'] ?? json['posterId'] ?? '').toString(),
      runnerId: (json['defendantId'] ?? json['runnerId'] ?? '').toString(),
      posterName: json['complainantName'] ?? 'Unknown',
      runnerName: json['defendantName'] ?? 'Unknown',
      resolution: json['adminNotes'] ?? json['resolution'],
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt']) 
          : null,
      evidenceUris: (json['evidenceUrls'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'posterId': posterId,
      'runnerId': runnerId,
      'posterName': posterName,
      'runnerName': runnerName,
      'resolution': resolution,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'evidenceUris': evidenceUris,
    };
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String get statusDisplay {
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
} 