package com.gigs.userservice.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(unique = true, nullable = false)
    private String username;
    private String firstName;
    private String lastName;
    @Column(unique = true, nullable = false)
    private String email;
    private String phoneNumber;
    private boolean isVerified;
    private double balance;
    @Column(name = "keycloak_id")
    private String keycloakId;

    private String profileUrl;
}