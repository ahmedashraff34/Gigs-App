package com.gigs.api_gateway.authentication.DTO;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateBasicProfileBody {
    private String firstName;
    private String lastName;
    private String email;
    private String phoneNumber;
}