package com.example.offerservice.client;



//import com.offer_service.dto.TaskDTO;
import com.example.offerservice.DTO.response.TaskResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;

// Replace "task-service" with your service name from Eureka/Discovery/Config
@FeignClient(name = "task-service")
public interface TaskClient {

    @GetMapping("api/tasks/regular/{taskId}")
    TaskResponse getTaskById(@PathVariable("taskId") Long taskId);
    @GetMapping("api/tasks/{id}/exists")
    Boolean doesTaskExist(@PathVariable("id") Long taskId);
    @PutMapping("api/tasks/{id}/accept")
    void acceptRegularTaskOffer(@PathVariable("id") Long taskId,
                                @RequestParam Long taskPosterId,
                                @RequestParam Long runnerId,
                                @RequestParam double amount);
}
