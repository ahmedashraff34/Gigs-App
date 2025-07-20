package com.example.offerservice.DTO.response;

import com.example.offerservice.Model.OfferStatus;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OfferResponse {
    private Long offerId;
    private Long runnerId;
    //new
    private Long taskId;
    private double amount;
    private String comment;
    private OfferStatus status;
    private String runnerName;
    private String runnerProfilePic;

}
