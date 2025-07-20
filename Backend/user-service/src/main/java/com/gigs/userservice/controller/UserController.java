// src/main/java/com/gigs/userservice/controller/AuthController.java
package com.gigs.userservice.controller;

import com.gigs.userservice.dto.request.AddUserBody;
import com.gigs.userservice.dto.request.UpdateBasicProfileBody;
import com.gigs.userservice.dto.response.UserResponse;
import com.gigs.userservice.service.UserService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
@Validated
@CrossOrigin(origins = "http://localhost:5173")
public class UserController {

    private final UserService userService;

    @PostMapping("/addUser")
    public ResponseEntity<Map<String, Object>> addUser(@RequestBody @Validated AddUserBody req) {
        try {
            Long userId = userService.addUser(req); // now returns ID

            Map<String, Object> response = new HashMap<>();
            response.put("message", "User added successfully");
            response.put("userId", userId);

            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", "User registration failed");
            error.put("details", e.getMessage());

            return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
        }
    }

    @GetMapping("/{id}")
    public UserResponse getById(@PathVariable Long id) {
        return userService.getUserById(id);
    }

    @PostMapping("/existsById")
    public ResponseEntity<Boolean> existsById(@RequestParam long id) {
        boolean exists = userService.userExistsById(id);
        return ResponseEntity.ok(exists);
    }

    @GetMapping("/all")
    public ResponseEntity<List<UserResponse>> getAllUsers() {
        List<UserResponse> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }

    @PutMapping("/{id}/add-balance")
    public ResponseEntity<String> addAmount(
            @PathVariable Long id,
            @RequestParam double amount) {
        try {
            userService.addAmount(id, amount);
            return ResponseEntity.ok("Amount added successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error adding amount: " + e.getMessage());
        }
    }

    @PutMapping("/{id}/deduct-balance")
    public ResponseEntity<String> deductAmount(
            @PathVariable Long id,
            @RequestParam double amount) {
        try {
            userService.deductAmount(id, amount);
            return ResponseEntity.ok("Amount deducted successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error deducting amount: " + e.getMessage());
        }
    }

    @PutMapping("/profile/basic")
    public ResponseEntity<?> updateBasicProfile(@RequestParam("userId") Long userId,
                                                @RequestBody UpdateBasicProfileBody body) {
        try {
            userService.updateBasicProfile(userId, body);
            return ResponseEntity.ok("Profile updated");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (NoSuchElementException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "User not found"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "An unexpected error occurred"));
        }
    }

    @PutMapping("/keycloak-id")
    public ResponseEntity<?> attachKeycloakId(@RequestParam Long userId, @RequestParam String keycloakId) {
        try {
            userService.attachKeycloakId(userId, keycloakId);
            return ResponseEntity.ok("Keycloak ID attached");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @PatchMapping("/{id}/profile-url")
    public ResponseEntity<String> updateProfileUrl(
            @PathVariable Long id,
            @RequestParam String profileUrl) {

        try {
            userService.updateProfileUrl(id, profileUrl);
            return ResponseEntity.ok("Profile URL updated successfully.");
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("An unexpected error occurred: " + e.getMessage());
        }
    }




}