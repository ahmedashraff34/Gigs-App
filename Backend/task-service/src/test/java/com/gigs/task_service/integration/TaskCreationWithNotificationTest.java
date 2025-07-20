package com.gigs.task_service.integration;

import com.gigs.task_service.dto.request.RegularTaskRequest;
import com.gigs.task_service.service.NotificationService;
import com.gigs.task_service.service.TaskService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

@SpringBootTest
@ActiveProfiles("test")
class TaskCreationWithNotificationTest {

    @Autowired
    private TaskService taskService;

    @MockBean
    private NotificationService notificationService;

    @Test
    void testTaskCreationTriggersNotification() {
        // Arrange
        RegularTaskRequest taskRequest = new RegularTaskRequest();
        taskRequest.setTitle("Test Task");
        taskRequest.setDescription("Test Description");
        taskRequest.setType("cleaning");
        taskRequest.setTaskPoster(123L);
        taskRequest.setLongitude(40.7128);
        taskRequest.setLatitude(-74.0060);
        taskRequest.setAmount(100.0);

        // Act
        taskService.createTask(taskRequest);

        // Assert
        verify(notificationService).sendTaskCreatedNotification(
                eq(123L),  // userId (taskPoster)
                any(Long.class),  // taskId (will be generated)
                eq("Test Task")  // taskTitle
        );
    }
} 