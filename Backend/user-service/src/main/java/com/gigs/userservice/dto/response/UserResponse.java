package com.gigs.userservice.dto.response;

import com.gigs.userservice.model.User;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserResponse {
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String phoneNumber;
    private boolean isVerified;
    private String username;
    private double balance;
    private String keycloakId;

    public static UserResponse fromUser(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .email(user.getEmail())
                .phoneNumber(user.getPhoneNumber())
                .isVerified(user.isVerified())
                .username(user.getUsername())
                .keycloakId(user.getKeycloakId())
                .balance(user.getBalance())
                .build();
    }
}
