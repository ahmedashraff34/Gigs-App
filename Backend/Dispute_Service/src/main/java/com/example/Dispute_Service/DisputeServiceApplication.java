package com.example.Dispute_Service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableFeignClients
@EnableDiscoveryClient
public class DisputeServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(DisputeServiceApplication.class, args);
	}

}
