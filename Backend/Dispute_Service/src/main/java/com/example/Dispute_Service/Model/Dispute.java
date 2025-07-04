package com.example.Dispute_Service.Model;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Dispute {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long disputeId;

    private Long taskId;
    private Long raisedBy;
    private String reason;
    private Long defendantId;

    @Enumerated(EnumType.STRING)
    private DisputeStatus status;

    @Lob
    private String images; // or use @Type(JsonType.class) with custom mapping

    private LocalDateTime createdAt;
}

