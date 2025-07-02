package com.example.offerservice.Model;


import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "offers")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Offer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long offerId;

    private Long regularTask;

    private Long runnerId;

    private double amount;

    private String comment;

    @Enumerated(EnumType.STRING)
    private OfferStatus status;
}
