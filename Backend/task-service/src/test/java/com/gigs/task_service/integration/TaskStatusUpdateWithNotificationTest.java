package com.gigs.task_service.integration;

import com.gigs.task_service.model.TaskStatus;
import com.gigs.task_service.service.NotificationService;
import com.gigs.task_service.service.TaskService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

@SpringBootTest
@ActiveProfiles("test")
class TaskStatusUpdateWithNotificationTest {

    @Autowired
    private TaskService taskService;

    @MockBean
    private NotificationService notificationService;

    @Test
    void testTaskStatusUpdateTriggersNotification() {
        // Note: This test would require a task to exist in the database
        // In a real integration test, you would first create a task
        // then update its status and verify the notification is sent
        
        // For now, this is a placeholder test structure
        // The actual implementation would depend on your test data setup
        
        // Arrange - Create a task first (this would be done in a real test)
        // Task task = createTestTask();
        
        // Act - Update task status
        // ResponseEntity<?> response = taskService.updateTaskStatus(taskId, TaskStatus.IN_PROGRESS, userId);
        
        // Assert - Verify notification was sent
        // verify(notificationService).sendTaskStatusUpdateNotification(
        //     eq(userId),  // userId (taskPoster)
        //     eq(taskId),  // taskId
        //     eq("Test Task")  // taskTitle
        // );
    }
} 