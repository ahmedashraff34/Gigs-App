# Task Service Notification Integration

## Overview

The task service now automatically sends notifications when a new task is created and when task status is updated. This integration uses a simple HTTP client (RestTemplate) to call the notification service without using Feign clients.

## Configuration

### Application Properties

Add the following configuration to `application.properties`:

```properties
# Notification service configuration
notification.service.url=http://localhost:8091
```

### Default Configuration

If the `notification.service.url` property is not set, it defaults to `http://localhost:8091`.

## Implementation Details

### NotificationService

- **Location**: `src/main/java/com/gigs/task_service/service/NotificationService.java`
- **Purpose**: Handles HTTP communication with the notification service
- **Methods**: 
  - `sendTaskCreatedNotification(Long userId, Long taskId, String taskTitle)` - for task creation
  - `sendTaskStatusUpdateNotification(Long userId, Long taskId, String taskTitle)` - for status updates

### Integration Points

- **Task Creation**: The notification is triggered in the `TaskService.createTask()` method after a task is successfully saved to the database.
- **Status Update**: The notification is triggered in the `TaskService.updateTaskStatus()` method after a task status is successfully updated.

### Request Body Format

The notification service receives POST requests with the following JSON body format for both task creation and status updates:

```json
{
  "userId": 123,
  "taskId": 456,
  "taskTitle": "Clean the garage",
  "fcmToken": "dIL5__iqTl-pZFWBLG3EyN:APA91bE1ta_CKDNFvSZ4U5gAWK70xsfoUKmYjMowoV3CZbaK3YP_BWwADyOIyh1ugqxvwZFUOHQ9OuX7P3WwE3MKxEX-j4se9QDChQXK-WmQPwWCGP_UH0E"
}
```

**Endpoints:**
- Task Creation: `POST /api/notifications/task-posted`
- Status Update: `POST /api/notifications/task-update`

### Error Handling

- If the notification service is unavailable or returns an error, the exception is logged but does not prevent task creation or status updates
- The task creation and status update processes continue normally even if notification fails
- All errors are logged to the console for debugging purposes

## Testing

### Unit Tests

- **Location**: `src/test/java/com/gigs/task_service/service/NotificationServiceTest.java`
- **Coverage**: Tests successful notification sending and error handling for both task creation and status updates

### Integration Tests

- **Location**: `src/test/java/com/gigs/task_service/integration/TaskCreationWithNotificationTest.java`
- **Coverage**: Tests that task creation triggers notification service
- **Location**: `src/test/java/com/gigs/task_service/integration/TaskStatusUpdateWithNotificationTest.java`
- **Coverage**: Tests that task status updates trigger notification service

## Usage

The notifications are automatically sent in the following scenarios:

1. **Task Creation**: When a new task is created through the `/api/tasks/postTask` endpoint
2. **Status Update**: When a task status is updated through the `/api/tasks/{taskId}/status` endpoint

No additional code is required in the controller or service layer.

## Monitoring

Check the application logs for notification-related messages:
- Task Creation Success: "Task creation notification sent successfully. Response: [status_code]"
- Task Creation Error: "Failed to send notification for task creation: [error_message]"
- Status Update Success: "Task status update notification sent successfully. Response: [status_code]"
- Status Update Error: "Failed to send notification for task status update: [error_message]"

## Dependencies

- Spring Web (for RestTemplate)
- Jackson (for JSON serialization)
- No additional external dependencies required 