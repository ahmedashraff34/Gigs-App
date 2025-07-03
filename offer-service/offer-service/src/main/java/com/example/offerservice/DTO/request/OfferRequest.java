package com.example.offerservice.DTO.request;


import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OfferRequest {
    private Long taskId;
    private Long runnerId;
    private double amount;
    private String comment;
}
