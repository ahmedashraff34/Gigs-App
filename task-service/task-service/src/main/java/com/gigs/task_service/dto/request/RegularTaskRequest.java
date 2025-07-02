package com.gigs.task_service.dto.request;

import com.fasterxml.jackson.databind.JsonNode;
import com.vladmihalcea.hibernate.type.json.JsonType;
import jakarta.persistence.Column;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import org.hibernate.annotations.Type;

public class RegularTaskRequest extends TaskRequest {

    @NotNull(message = "Amount is required for regular tasks")
    @Positive(message = "Amount must be greater than zero")
    private Double amount;



    @Type(JsonType.class)
    @Column(columnDefinition = "json")
    private JsonNode additionalAttributes;

    // Getters and Setters
    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }


    public JsonNode getAdditionalAttributes() {
        return additionalAttributes;
    }

    public void setAdditionalAttributes(JsonNode additionalAttributes) {
        this.additionalAttributes = additionalAttributes;
    }

}
