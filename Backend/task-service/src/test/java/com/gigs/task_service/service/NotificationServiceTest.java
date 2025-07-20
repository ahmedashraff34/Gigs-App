package com.gigs.task_service.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    private NotificationService notificationService;

    @Test
    void testSendTaskCreatedNotification_Success() {
        // Arrange
        Long userId = 123L;
        Long taskId = 456L;
        String taskTitle = "Clean the garage";
        
        // Set the notification service URL
        ReflectionTestUtils.setField(notificationService, "notificationServiceUrl", "http://localhost:8091");
        
        // Mock the RestTemplate response
        ResponseEntity<String> mockResponse = new ResponseEntity<>("Success", HttpStatus.OK);
        when(restTemplate.postForEntity(any(String.class), any(HttpEntity.class), eq(String.class)))
                .thenReturn(mockResponse);

        // Act
        notificationService.sendTaskCreatedNotification(userId, taskId, taskTitle);

        // Assert
        verify(restTemplate, times(1)).postForEntity(
                eq("http://localhost:8091/api/notifications/task-completed"),
                any(HttpEntity.class),
                eq(String.class)
        );
    }

    @Test
    void testSendTaskCreatedNotification_Exception() {
        // Arrange
        Long userId = 123L;
        Long taskId = 456L;
        String taskTitle = "Clean the garage";
        
        // Set the notification service URL
        ReflectionTestUtils.setField(notificationService, "notificationServiceUrl", "http://localhost:8091");
        
        // Mock the RestTemplate to throw an exception
        when(restTemplate.postForEntity(any(String.class), any(HttpEntity.class), eq(String.class)))
                .thenThrow(new RuntimeException("Network error"));

        // Act & Assert - should not throw exception
        notificationService.sendTaskCreatedNotification(userId, taskId, taskTitle);
        
        // Verify the method was called
        verify(restTemplate, times(1)).postForEntity(
                eq("http://localhost:8091/api/notifications/task-posted"),
                any(HttpEntity.class),
                eq(String.class)
        );
    }

    @Test
    void testSendTaskStatusUpdateNotification_Success() {
        // Arrange
        Long userId = 123L;
        Long taskId = 456L;
        String taskTitle = "Clean the garage";
        
        // Set the notification service URL
        ReflectionTestUtils.setField(notificationService, "notificationServiceUrl", "http://localhost:8091");
        
        // Mock the RestTemplate response
        ResponseEntity<String> mockResponse = new ResponseEntity<>("Success", HttpStatus.OK);
        when(restTemplate.postForEntity(any(String.class), any(HttpEntity.class), eq(String.class)))
                .thenReturn(mockResponse);

        // Act
        notificationService.sendTaskStatusUpdateNotification(userId, taskId, taskTitle);

        // Assert
        verify(restTemplate, times(1)).postForEntity(
                eq("http://localhost:8091/api/notifications/task-update"),
                any(HttpEntity.class),
                eq(String.class)
        );
    }

    @Test
    void testSendTaskStatusUpdateNotification_Exception() {
        // Arrange
        Long userId = 123L;
        Long taskId = 456L;
        String taskTitle = "Clean the garage";
        
        // Set the notification service URL
        ReflectionTestUtils.setField(notificationService, "notificationServiceUrl", "http://localhost:8091");
        
        // Mock the RestTemplate to throw an exception
        when(restTemplate.postForEntity(any(String.class), any(HttpEntity.class), eq(String.class)))
                .thenThrow(new RuntimeException("Network error"));

        // Act & Assert - should not throw exception
        notificationService.sendTaskStatusUpdateNotification(userId, taskId, taskTitle);
        
        // Verify the method was called
        verify(restTemplate, times(1)).postForEntity(
                eq("http://localhost:8091/api/notifications/task-update"),
                any(HttpEntity.class),
                eq(String.class)
        );
    }
} 