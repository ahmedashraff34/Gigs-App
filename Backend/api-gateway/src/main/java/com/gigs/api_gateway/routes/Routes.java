package com.gigs.api_gateway.routes;

import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class Routes {

    @Bean
    public RouteLocator customRoutes(RouteLocatorBuilder builder) {
        return builder.routes()

                .route("user-service", r -> r
                        .path("/api/user/**")
                        .uri("lb://user-service"))  // Load balanced via Eureka

                .route("task-service", r -> r
                        .path("/api/tasks/**")
                        .uri("lb://task-service"))

                .build();
    }
}
