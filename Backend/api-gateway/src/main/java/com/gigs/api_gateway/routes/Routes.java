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
                .route("offer-service", r -> r
                        .path("/api/offers/**")
                        .uri("lb://offer-service"))

                .route("event-service", r -> r
                        .path("/api/events/**")
                        .uri("lb://event-service"))

                .route("payment-service", r -> r
                        .path("/api/payments/**")
                        .uri("lb://payment-service"))

                .route("dispute-service", r -> r
                        .path("/api/disputes/**")
                        .uri("lb://dispute-service"))
                .route("admin-dispute-service", r -> r
                        .path("/api/admin/disputes/**")
                        .uri("lb://dispute-service"))


                .build();
    }
}
