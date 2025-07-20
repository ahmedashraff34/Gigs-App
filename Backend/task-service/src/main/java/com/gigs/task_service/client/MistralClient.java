package com.gigs.task_service.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.Map;

@FeignClient(name = "mistralClient", url = "http://localhost:11434")
public interface MistralClient {
    @PostMapping("/api/generate")
    String generatePrompt(@RequestBody Map<String, Object> body);
}
