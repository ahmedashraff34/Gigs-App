package com.gigs.userservice.dto.request;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateBasicProfileBody {
    private String username;
    private String firstName;
    private String lastName;
    private String email;
    private String phoneNumber;
}