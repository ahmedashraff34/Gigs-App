package com.example.offerservice.Service;

import com.example.offerservice.DTO.request.OfferRequest;
import com.example.offerservice.DTO.response.OfferResponse;
import com.example.offerservice.DTO.response.TaskResponse;
import com.example.offerservice.Model.Offer;
import com.example.offerservice.Model.OfferStatus;
import com.example.offerservice.client.TaskClient;
import com.example.offerservice.repository.OfferRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class OfferService {

    private final OfferRepository offerRepo;
    private final TaskClient taskClient;

    @Autowired
    public OfferService(OfferRepository offerRepo, TaskClient taskClient) {
        this.offerRepo = offerRepo;
        this.taskClient = taskClient;
    }

    /**
     * Retrieves all offers related to a specific task.
     */
    public List<OfferResponse> getOffersForTask(Long taskId) {
        return offerRepo.findByRegularTask(taskId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Validates and places a new offer.
     */
    public boolean validateAndProcessOffer(OfferRequest req) {
        if (req.getAmount() <= 0 || req.getTaskId() == null || req.getRunnerId() == null) {
            return false;
        }

        // Optional cross-service validation
        boolean taskExists = taskClient.doesTaskExist(req.getTaskId());
        if (!taskExists) {
            return false;
        }

        // ✅ Prevent duplicate offer from same runner on this task
        boolean alreadyOffered = offerRepo.existsByRunnerIdAndRegularTask(req.getRunnerId(), req.getTaskId());
        if (alreadyOffered) {
            return false;
        }

        // ✅ Prevent placing offer if one is already accepted
        List<Offer> offersForTask = offerRepo.findByRegularTask(req.getTaskId());
        boolean taskHasAcceptedOffer = offersForTask.stream()
                .anyMatch(o -> o.getStatus() == OfferStatus.ACCEPTED);
        if (taskHasAcceptedOffer) {
            return false;
        }

        placeOffer(req);
        return true;
    }



    /**
     * Places a new offer.
     */
    public Offer placeOffer(OfferRequest req) {

        Offer offer = new Offer();
        offer.setRegularTask(req.getTaskId());
        offer.setRunnerId(req.getRunnerId());
        offer.setAmount(req.getAmount());
        offer.setComment(req.getComment());
        offer.setStatus(OfferStatus.PENDING);
        return offerRepo.save(offer);
    }

    /**
     * Deletes all offers related to a specific task.
     */
    @Transactional
    public boolean deleteOffersForTask(Long taskId) {
        try {
            int deletedCount = offerRepo.deleteByRegularTask(taskId);
            return true;
        } catch (Exception e) {
            return false;
        }
    }


    //delete offer by id
    public boolean cancelOffer(Long offerId) {
        if (!offerRepo.existsById(offerId)) {
            return false;
        }
       if(offerRepo.findById(offerId).get().getStatus().equals(OfferStatus.PENDING)){
            offerRepo.deleteById(offerId);
            return true;
       }
       else {
            return false;
       }
    }

    /**
     * Updates the status of a specific offer.
     */
    public boolean updateOfferStatus(Long taskId, OfferStatus newStatus) {
        List<Offer> offers = offerRepo.findByRegularTask(taskId);

        if (offers.isEmpty()) return false;

        if (offers.size() > 1) {
            System.err.println("Warning: More than one offer found for task ID: " + taskId);
        }

        Offer offer = offers.get(0);
        if (offer.getStatus() == newStatus) return false;

        offer.setStatus(newStatus);
        offerRepo.save(offer);
        return true;
    }


    /** public boolean updateOfferStatus(Long offerId, OfferStatus newStatus) {
     return offerRepo.findById(offerId).map(offer -> {
     if (offer.getStatus() == newStatus){
     return false; //status already set to newStatus
     }
     offer.setStatus(newStatus);
     offerRepo.save(offer);
     return true;
     }).orElse(false);
     }/

    /**
     * Accepts a specific offer for a given task.
     */
    public boolean acceptOffer(Long taskId, Long offerId, Long taskPosterId) {
        // 🔍 First, check if another offer is already accepted for this task
        List<Offer> offers = offerRepo.findByRegularTask(taskId);
        boolean alreadyAccepted = offers.stream()
                .anyMatch(o -> o.getStatus() == OfferStatus.ACCEPTED);

        if (alreadyAccepted) {
            // 🔴 Prevent accepting a new offer if one is already accepted
            return false;
        }

        return offerRepo.findById(offerId).map(offer -> {
            if (offer.getRegularTask().equals(taskId)) {
                if (offer.getStatus() == OfferStatus.ACCEPTED) {
                    return false;
                }

                // 🟢 Accept this offer
                try {
                    offer.setStatus(OfferStatus.ACCEPTED);
                    offerRepo.save(offer);
                } catch (Exception e) {
                    System.err.println("Failed to save accepted offer: " + e.getMessage());
                    return false;
                }

                // ❌ Delete all other offers on the same task except this one
                try {
                    offerRepo.deleteOtherOffersForTask(taskId, offer.getOfferId());
                } catch (Exception e) {
                    System.err.println("Failed to delete other offers: " + e.getMessage());
                    return false;
                }

                // ✅ Update the task status using taskClient
                try {
                    taskClient.acceptRegularTaskOffer(taskId, taskPosterId, offer.getRunnerId(), offer.getAmount());
                } catch (Exception e) {
                    System.err.println("Failed to update task status: " + e.getMessage());
                    return false;
                }

                return true;
            }
            return false;
        }).orElse(false);
    }




    /**
     * Gets all task IDs where the runner has accepted offers.

    public List<Long> getAcceptedOffersTasks(Long runnerId) {
        return offerRepo.findByRunnerIdAndStatus(runnerId, OfferStatus.ACCEPTED)
                .stream()
                .map(Offer::getRegularTask)
                .collect(Collectors.toList());
    }
    */
    public List<TaskResponse> getAcceptedOffersTasks(Long runnerId) {
        List<Long> taskIds = offerRepo.findByRunnerIdAndStatus(runnerId, OfferStatus.ACCEPTED)
                .stream()
                .map(Offer::getRegularTask) // assumes this is a Long task ID
                .collect(Collectors.toList());

        return taskIds.stream()
                .map(taskId -> taskClient.getTaskById(taskId)) // fetch each full task
                .collect(Collectors.toList());
    }
    //retrive offers placed by a certain runner 34an ye view kol el offers bt3to
    public List<OfferResponse> getOffersByRunner(Long runnerId) {
        return offerRepo.findByRunnerId(runnerId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Converts an Offer entity to a DTO.
     * (Runner name/profile would typically be fetched from another microservice, so placeholders here.)
     */
    public OfferResponse mapToDTO(Offer offer) {
        OfferResponse dto = new OfferResponse();
        dto.setOfferId(offer.getOfferId());
        dto.setRunnerId(offer.getRunnerId());
        //new
        dto.setTaskId(offer.getRegularTask());
        dto.setAmount(offer.getAmount());
        dto.setComment(offer.getComment());
        dto.setStatus(offer.getStatus());

        // Placeholder - ideally fetched from user-service
        dto.setRunnerName("Runner Name Placeholder");
        dto.setRunnerProfilePic("Runner Pic Placeholder");
        return dto;
    }
}
