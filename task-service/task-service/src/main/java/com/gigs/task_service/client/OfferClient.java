package com.gigs.task_service.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(
        name = "offer-service"
)
public interface OfferClient {
    @DeleteMapping(
            value="api/offers/task/{taskId}")
     void deleteOffers(@PathVariable Long taskId);

    // Update the status of an offer
    @PutMapping(
            value = "api/offers/{offerId}/status")
    public void updateOfferStatus(@PathVariable Long offerId, @RequestParam String status);
}
