// src/main/java/com/gigs/userservice/service/UserService.java
package com.gigs.userservice.service;

import com.gigs.userservice.dto.request.AddUserBody;
import com.gigs.userservice.dto.request.UpdateBasicProfileBody;
import com.gigs.userservice.dto.response.UserResponse;
import com.gigs.userservice.model.User;
import com.gigs.userservice.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    public long addUser(AddUserBody req) {
        User user = User.builder().username(req.getUsername())
                .firstName(req.getFirstName())
                .lastName(req.getLastName())
                .email(req.getEmail())
                .phoneNumber(req.getPhoneNumber())
                .isVerified(false)
                .balance(5000)
                .build();

        User savedUser = userRepository.save(user); // <- fix here
        return savedUser.getId();
    }

    public boolean userExistsById(long id) {
        return userRepository.findById(id).isPresent();
    }

    public UserResponse getUserById(Long id) {
        User u = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
        return UserResponse.fromUser(u);
    }

    public List<UserResponse> getAllUsers() {
        return userRepository.findAll()
                .stream()
                .map(UserResponse::fromUser)
                .collect(Collectors.toList());
    }

    public void addAmount(long id, double amount) {
        if (amount < 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }

        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + id));

        user.setBalance(user.getBalance() + amount);
        userRepository.save(user);
    }

    public void deductAmount(long id, double amount) {
        if (amount < 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }

        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + id));

        double newBalance = user.getBalance() - amount;
        if (newBalance < 0) {
            throw new IllegalStateException("Insufficient balance");
        }

        user.setBalance(newBalance);
        userRepository.save(user);
    }

    public void updateBasicProfile(Long userId, UpdateBasicProfileBody body) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NoSuchElementException("User not found"));

        boolean updated = false;

        if (body.getFirstName() != null && !body.getFirstName().equals(user.getFirstName())) {
            user.setFirstName(body.getFirstName());
            updated = true;
        }
        if (body.getLastName() != null && !body.getLastName().equals(user.getLastName())) {
            user.setLastName(body.getLastName());
            updated = true;
        }
        if (body.getEmail() != null && !body.getEmail().equals(user.getEmail())) {
            user.setEmail(body.getEmail());
            updated = true;
        }
        if (body.getPhoneNumber() != null && !body.getPhoneNumber().equals(user.getPhoneNumber())) {
            user.setPhoneNumber(body.getPhoneNumber());
            updated = true;
        }
        if (body.getProfileUrl() != null){
            user.setProfileUrl(body.getProfileUrl());
            updated = true;
        }

        if (!updated) {
            throw new IllegalArgumentException("No changes detected in the profile");
        }

        userRepository.save(user);
    }


    public void attachKeycloakId(Long userId, String keycloakId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NoSuchElementException("User not found"));
        user.setKeycloakId(keycloakId);
        userRepository.save(user);
    }

    public void updateProfileUrl(Long userId, String profileUrl) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found with id: " + userId));

        user.setProfileUrl(profileUrl);
        userRepository.save(user);
    }




}