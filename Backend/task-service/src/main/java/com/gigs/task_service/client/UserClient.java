package com.gigs.task_service.client;


import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(
        name = "user-service"
)
public interface UserClient {

    @PostMapping(
            value    = "/api/user/existsById"
    )
    Boolean existsById(@RequestParam long id);

}
