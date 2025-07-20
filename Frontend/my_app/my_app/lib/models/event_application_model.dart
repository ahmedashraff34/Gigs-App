class EventApplication {
  final int taskId;
  final int applicantId;
  final String comment;
  final String resumeLink;

  EventApplication({
    required this.taskId,
    required this.applicantId,
    required this.comment,
    required this.resumeLink,
  });

  factory EventApplication.fromJson(Map<String, dynamic> json) {
    return EventApplication(
      taskId: json['taskId'],
      applicantId: json['applicantId'],
      comment: json['comment'],
      resumeLink: json['resumeLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'applicantId': applicantId,
      'comment': comment,
      'resumeLink': resumeLink,
    };
  }
}

enum ApplicationStatus {
  PENDING,
  ACCEPTED,
  REJECTED,
  CANCELLED,
}

class EventAppResponse {
  final int applicationId;
  final int taskId;
  final int applicantId;
  final String comment;
  final String resumeLink;
  final String status;

  EventAppResponse({
    required this.applicationId,
    required this.taskId,
    required this.applicantId,
    required this.comment,
    required this.resumeLink,
    required this.status,
  });

  factory EventAppResponse.fromJson(Map<String, dynamic> json) {
    return EventAppResponse(
      applicationId: json['applicationId'],
      taskId: json['taskId'],
      applicantId: json['applicantId'],
      comment: json['comment'],
      resumeLink: json['resumeLink'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'taskId': taskId,
      'applicantId': applicantId,
      'comment': comment,
      'resumeLink': resumeLink,
      'status': status,
    };
  }
}
