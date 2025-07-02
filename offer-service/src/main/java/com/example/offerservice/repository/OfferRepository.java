package com.example.offerservice.repository;

import com.example.offerservice.Model.Offer;
import com.example.offerservice.Model.OfferStatus;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

    public interface OfferRepository extends JpaRepository<Offer, Long> {
        List<Offer> findByRegularTask(Long taskId);
        List<Offer> findByRunnerIdAndStatus(Long runnerId, OfferStatus status);
        List<Offer> findByRunnerId(Long runnerId);
        List<Offer> findByRegularTaskAndStatus(Long taskId, OfferStatus status);

        @Modifying
        @Transactional
        int deleteByRegularTask(Long taskId);

        boolean existsByRunnerIdAndRegularTask(Long runnerId, Long taskId);



        @Modifying
        @Transactional
        @Query("DELETE FROM Offer o WHERE o.regularTask = :taskId AND o.offerId <> :offerIdToKeep")
        void deleteOtherOffersForTask(@Param("taskId") Long taskId,
                                      @Param("offerIdToKeep") Long offerIdToKeep);


    }



