package com.gigs.api_gateway.authentication.controller;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gigs.api_gateway.authentication.DTO.LoginDTO;
import com.gigs.api_gateway.authentication.DTO.SignUpDTO;
import com.gigs.api_gateway.authentication.DTO.UpdateBasicProfileBody;
import org.springframework.http.*;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {
    private final String KEYCLOAK_URL = "http://localhost:8083";
    private final String REALM = "gigsKC";
    private final String CLIENT_ID = "gigs-api-gateway";
    private final String CLIENT_SECRET = "PPre7UbfPo9AqXy3dvkPyXrCwXt4hFPs";

    @PostMapping("/login")
    public ResponseEntity<Map> login(@RequestBody LoginDTO request) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "password");
        form.add("client_id", CLIENT_ID);
        form.add("client_secret", CLIENT_SECRET);
        form.add("username", request.getUsername());
        form.add("password", request.getPassword());

        try {
            // Request token from Keycloak
            ResponseEntity<Map> response = restTemplate.postForEntity(
                    KEYCLOAK_URL + "/realms/" + REALM + "/protocol/openid-connect/token",
                    new HttpEntity<>(form, headers),
                    Map.class
            );

            Map<String, Object> tokenData = response.getBody();
            String accessToken = (String) tokenData.get("access_token");

            // Decode JWT payload to extract numeric_id
            String[] tokenParts = accessToken.split("\\.");
            Base64.Decoder decoder = Base64.getUrlDecoder();
            String payload = new String(decoder.decode(tokenParts[1]));

            ObjectMapper objectMapper = new ObjectMapper();
            Map<String, Object> tokenPayload = objectMapper.readValue(payload, Map.class);

            // Extract custom numeric_id claim
            Long numericId = null;
            if (tokenPayload.get("numeric_id") != null) {
                numericId = Long.parseLong(tokenPayload.get("numeric_id").toString());
            }

            // Add user_id to response
            Map<String, Object> responseBody = new HashMap<>(tokenData);
            responseBody.put("user_id", numericId);

            return ResponseEntity.ok(responseBody);

        } catch (Exception e) {
            e.printStackTrace();

            Map<String, Object> errorBody = new HashMap<>();
            errorBody.put("error", "Invalid login");
            errorBody.put("details", e.getMessage());

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorBody);
        }
    }

    @PostMapping("/register")
    public ResponseEntity<String> signup(@RequestBody SignUpDTO request) {
        RestTemplate restTemplate = new RestTemplate();

        try {
            // Step 1: Create user in user-service
            HttpHeaders serviceHeaders = new HttpHeaders();
            serviceHeaders.setContentType(MediaType.APPLICATION_JSON);

            Map<String, Object> addUserBody = new HashMap<>();
            addUserBody.put("username", request.getUsername());
            addUserBody.put("firstName", request.getFirstName());
            addUserBody.put("lastName", request.getLastName());
            addUserBody.put("email", request.getEmail());
            addUserBody.put("phoneNumber", request.getPhoneNumber());
            addUserBody.put("balance", request.getBalance());

            ResponseEntity<Map> userServiceResponse = restTemplate.postForEntity(
                    "http://localhost:8085/api/user/addUser",
                    new HttpEntity<>(addUserBody, serviceHeaders),
                    Map.class
            );

            if (!userServiceResponse.getStatusCode().is2xxSuccessful()) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body("Failed to create user in user microservice");
            }

            Long userId = Long.parseLong(userServiceResponse.getBody().get("userId").toString());

            // Step 2: Get Keycloak Admin Token
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
            form.add("grant_type", "password");
            form.add("client_id", "admin-cli");
            form.add("username", "admin");
            form.add("password", "admin");

            ResponseEntity<Map> tokenResponse = restTemplate.postForEntity(
                    KEYCLOAK_URL + "/realms/master/protocol/openid-connect/token",
                    new HttpEntity<>(form, headers), Map.class
            );

            String adminToken = (String) tokenResponse.getBody().get("access_token");

            // Step 3: Create user in Keycloak with numeric_id
            HttpHeaders userHeaders = new HttpHeaders();
            userHeaders.setContentType(MediaType.APPLICATION_JSON);
            userHeaders.setBearerAuth(adminToken);

            Map<String, Object> newUser = new HashMap<>();
            newUser.put("username", request.getUsername());
            newUser.put("email", request.getEmail());
            newUser.put("firstName", request.getFirstName());
            newUser.put("lastName", request.getLastName());
            newUser.put("enabled", true);
            newUser.put("emailVerified", true);
            newUser.put("attributes", Map.of("numeric_id", List.of(String.valueOf(userId))));

            Map<String, Object> passwordMap = new HashMap<>();
            passwordMap.put("type", "password");
            passwordMap.put("value", request.getPassword());
            passwordMap.put("temporary", false);
            newUser.put("credentials", List.of(passwordMap));

            restTemplate.postForEntity(
                    KEYCLOAK_URL + "/admin/realms/" + REALM + "/users",
                    new HttpEntity<>(newUser, userHeaders),
                    String.class
            );

            // Step 4: Get created Keycloak ID by username
            ResponseEntity<List> searchResponse = restTemplate.exchange(
                    KEYCLOAK_URL + "/admin/realms/" + REALM + "/users?username=" + request.getUsername(),
                    HttpMethod.GET,
                    new HttpEntity<>(userHeaders),
                    List.class
            );

            if (searchResponse.getBody().isEmpty()) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Keycloak user not found after creation");
            }

            String keycloakId = ((Map<String, Object>) searchResponse.getBody().get(0)).get("id").toString();

            String updateKeycloakUrl = "http://localhost:8085/api/user/keycloak-id?userId=" + userId + "&keycloakId=" + keycloakId;

            HttpHeaders updateHeaders = new HttpHeaders();
            HttpEntity<Void> updateRequest = new HttpEntity<>(updateHeaders);

            restTemplate.exchange(
                    updateKeycloakUrl,
                    HttpMethod.PUT,
                    updateRequest,
                    String.class
            );

            return ResponseEntity.ok("User registered successfully.");

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error: " + e.getMessage());
        }
    }

    @PutMapping("/profile/basic")
    public ResponseEntity<?> updateProfile(@RequestParam("userId") Long userId,
                                           @RequestBody UpdateBasicProfileBody body) {
        RestTemplate restTemplate = new RestTemplate();

        try {
            // STEP 1: Update user in your user microservice
            HttpHeaders serviceHeaders = new HttpHeaders();
            serviceHeaders.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<UpdateBasicProfileBody> userRequest = new HttpEntity<>(body, serviceHeaders);

            restTemplate.exchange(
                    "http://localhost:8085/api/user/profile/basic?userId=" + userId,
                    HttpMethod.PUT,
                    userRequest,
                    String.class
            );

            // STEP 2: Get Keycloak Admin token
            HttpHeaders tokenHeaders = new HttpHeaders();
            tokenHeaders.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

            MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
            form.add("grant_type", "password");
            form.add("client_id", "admin-cli");
            form.add("username", "admin");
            form.add("password", "admin");

            ResponseEntity<Map> tokenResponse = restTemplate.postForEntity(
                    KEYCLOAK_URL + "/realms/master/protocol/openid-connect/token",
                    new HttpEntity<>(form, tokenHeaders),
                    Map.class
            );

            String adminToken = (String) tokenResponse.getBody().get("access_token");

            // STEP 3: Get keycloakId from user-service
            ResponseEntity<Map> userResponse = restTemplate.getForEntity(
                    "http://localhost:8085/api/user/" + userId,
                    Map.class
            );

            String keycloakId = userResponse.getBody().get("keycloakId").toString();

            // STEP 4: Update user in Keycloak
            HttpHeaders kcHeaders = new HttpHeaders();
            kcHeaders.setBearerAuth(adminToken);
            kcHeaders.setContentType(MediaType.APPLICATION_JSON);

            Map<String, Object> kcBody = new HashMap<>();
            if (body.getFirstName() != null) kcBody.put("firstName", body.getFirstName());
            if (body.getLastName() != null) kcBody.put("lastName", body.getLastName());
            if (body.getEmail() != null) kcBody.put("email", body.getEmail());

            HttpEntity<Map<String, Object>> kcRequest = new HttpEntity<>(kcBody, kcHeaders);

            restTemplate.exchange(
                    KEYCLOAK_URL + "/admin/realms/" + REALM + "/users/" + keycloakId,
                    HttpMethod.PUT,
                    kcRequest,
                    String.class
            );

            return ResponseEntity.ok("User and Keycloak profile updated.");

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Update failed: " + e.getMessage()));
        }
    }




    @GetMapping("/test")
    public String test() {
        System.out.println("✅ Test endpoint hit");
        return "ok";
    }

}
