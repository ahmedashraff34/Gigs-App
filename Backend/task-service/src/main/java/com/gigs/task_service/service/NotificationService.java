package com.gigs.task_service.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class NotificationService {

    @Value("${notification.service.url:http://localhost:8091}")
    private String notificationServiceUrl;

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    public NotificationService() {
        this.restTemplate = new RestTemplate();
        this.objectMapper = new ObjectMapper();
    }

    public void sendTaskCreatedNotification(Long userId, Long taskId, String taskTitle) {
        try {
            String url = notificationServiceUrl + "/api/notifications/task-posted";
            
            Map<String, Object> notificationBody = new HashMap<>();
            notificationBody.put("userId", userId);
            notificationBody.put("taskId", taskId);
            notificationBody.put("taskTitle", taskTitle);
            notificationBody.put("fcmToken", "dIL5__iqTl-pZFWBLG3EyN:APA91bE1ta_CKDNFvSZ4U5gAWK70xsfoUKmYjMowoV3CZbaK3YP_BWwADyOIyh1ugqxvwZFUOHQ9OuX7P3WwE3MKxEX-j4se9QDChQXK-WmQPwWCGP_UH0E");

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(notificationBody, headers);

            ResponseEntity<String> response = restTemplate.postForEntity(url, request, String.class);
            
            // Log the response for debugging
            System.out.println("Task creation notification sent successfully. Response: " + response.getStatusCode());
            
        } catch (Exception e) {
            // Log the error but don't throw it to avoid breaking the task creation flow
            System.err.println("Failed to send notification for task creation: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void sendTaskStatusUpdateNotification(Long userId, Long taskId, String taskTitle) {
        try {
            String url = notificationServiceUrl + "/api/notifications/task-update";
            
            Map<String, Object> notificationBody = new HashMap<>();
            notificationBody.put("userId", userId);
            notificationBody.put("taskId", taskId);
            notificationBody.put("taskTitle", taskTitle);
            notificationBody.put("fcmToken", "dIL5__iqTl-pZFWBLG3EyN:APA91bE1ta_CKDNFvSZ4U5gAWK70xsfoUKmYjMowoV3CZbaK3YP_BWwADyOIyh1ugqxvwZFUOHQ9OuX7P3WwE3MKxEX-j4se9QDChQXK-WmQPwWCGP_UH0E");

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(notificationBody, headers);

            ResponseEntity<String> response = restTemplate.postForEntity(url, request, String.class);
            
            // Log the response for debugging
            System.out.println("Task status update notification sent successfully. Response: " + response.getStatusCode());
            
        } catch (Exception e) {
            // Log the error but don't throw it to avoid breaking the task status update flow
            System.err.println("Failed to send notification for task status update: " + e.getMessage());
            e.printStackTrace();
        }
    }
} 