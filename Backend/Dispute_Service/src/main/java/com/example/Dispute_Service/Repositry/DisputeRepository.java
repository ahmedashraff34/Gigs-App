package com.example.Dispute_Service.Repositry;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.Dispute_Service.Model.Dispute;
import com.example.Dispute_Service.Model.DisputeStatus;

public interface DisputeRepository extends JpaRepository<Dispute, Long> {
    
    /**
     * Find all disputes raised by a specific user
     */
    List<Dispute> findByRaisedBy(Long raisedBy);
    
    /**
     * Find all disputes where a user is the defendant
     */
    List<Dispute> findByDefendantId(Long defendantId);
    
    /**
     * Find all disputes by status
     */
    List<Dispute> findByStatus(DisputeStatus status);
    
    /**
     * Find all disputes for a specific task
     */
    List<Dispute> findByTaskId(Long taskId);
}

