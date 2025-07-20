package com.example.Dispute_Service.Client;

import org.springframework.stereotype.Component;

@Component
public class TaskClientFallback implements TaskClient {
    
    @Override
    public Boolean existsById(long id) {
        // Return false when service is unavailable
        return false;
    }
} 