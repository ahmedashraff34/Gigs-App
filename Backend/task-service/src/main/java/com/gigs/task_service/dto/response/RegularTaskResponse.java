package com.gigs.task_service.dto.response;

import com.fasterxml.jackson.databind.JsonNode;
import com.vladmihalcea.hibernate.type.json.JsonType;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.experimental.SuperBuilder;
import org.hibernate.annotations.Type;

@Data
@EqualsAndHashCode(callSuper = true)
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class RegularTaskResponse extends TaskResponse {
    private double amount;
    @Type(JsonType.class)
    private JsonNode additionalAttributes;
    private Long runnerId;
}