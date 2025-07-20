package com.example.eventservice.repository;

import com.example.eventservice.model.EventApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface EventApplicationRepository extends JpaRepository<EventApplication, Long> {

    boolean existsByApplicantIdAndEventTask(Long runnerId, Long taskId);

    Optional<EventApplication> findByApplicantIdAndEventTask(Long runnerId, Long taskId);

    List<EventApplication> findByEventTask(Long taskId);

    List<EventApplication> findByApplicantId(Long runnerId);

    // Count how many accepted applications exist for a task
    @Query("SELECT COUNT(e) FROM EventApplication e WHERE e.eventTask = :taskId AND e.status = 'APPROVED'")
    long countAcceptedApplicationsByTaskId(@Param("taskId") Long taskId);

    int deleteByEventTask(Long taskId); // Optional: used to mass-remove applications
}
