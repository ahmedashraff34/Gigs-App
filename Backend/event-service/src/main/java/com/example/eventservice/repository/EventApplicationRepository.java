package com.example.eventservice.repository;

import com.example.eventservice.model.EventApplication;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface EventApplicationRepository extends JpaRepository<EventApplication, Long> {

    boolean existsByApplicantIdAndEventTask(Long runnerId, Long taskId);

    Optional<EventApplication> findByApplicantIdAndEventTask(Long runnerId, Long taskId);

    List<EventApplication> findByEventTask(Long taskId);

    List<EventApplication> findByApplicantId(Long runnerId);

    int deleteByEventTask(Long taskId); // Optional: used to mass-remove applications
}
