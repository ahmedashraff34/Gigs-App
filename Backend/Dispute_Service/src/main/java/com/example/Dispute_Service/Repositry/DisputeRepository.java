package com.example.Dispute_Service.Repositry;

import com.example.Dispute_Service.Model.Dispute;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DisputeRepository extends JpaRepository<Dispute, Long> {
}

