package com.example.offerservice.Service;

import com.example.offerservice.DTO.request.OfferRequest;
import com.example.offerservice.DTO.response.OfferResponse;
import com.example.offerservice.DTO.response.TaskResponse;
import com.example.offerservice.Model.Offer;
import com.example.offerservice.Model.OfferStatus;
import com.example.offerservice.client.TaskClient;
import com.example.offerservice.client.UserClient;
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
    private final UserClient userClient;
    @Autowired
    public OfferService(OfferRepository offerRepo, TaskClient taskClient, UserClient userClient) {
        this.offerRepo = offerRepo;
        this.taskClient = taskClient;
        this.userClient = userClient;
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
        try{
        // ✅ Check if user exists (optional cross-service validation)
        if(!userClient.existsById(req.getRunnerId())){
            return false;
        }
        }catch (Exception e){
            System.err.println("Failed to check if user exits: "+e.getMessage());
        }

        try {
            // ✅ Check if task exists (optional cross-service validation)
            boolean taskExists = taskClient.doesTaskExist(req.getTaskId());
            if (!taskExists) {
                return false;
            }
        }catch (Exception e){
            System.err.println("Failed to check if task exists: "+e.getMessage());
        }

        // ✅ Prevent duplicate offer from same runner on this task
        boolean alreadyOffered = offerRepo.existsByRunnerIdAndRegularTask(req.getRunnerId(), req.getTaskId());
        if (alreadyOffered) {
            return false;
        }

        // ✅ Prevent placing offer if task already has an accepted offer
        List<Offer> offersForTask = offerRepo.findByRegularTask(req.getTaskId());
        boolean taskHasAcceptedOffer = offersForTask.stream()
                .anyMatch(o -> o.getStatus() == OfferStatus.ACCEPTED);
        if (taskHasAcceptedOffer) {
            return false;
        }

        // ✅ Prevent runner from placing offers if they already have an accepted one
        boolean runnerHasAcceptedOffer = offerRepo.existsByRunnerIdAndStatus(req.getRunnerId(), OfferStatus.ACCEPTED);
        if (runnerHasAcceptedOffer) {
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
    @Transactional
    public boolean acceptOfferTransactional(Long taskId, Long offerId) {
        // 🔍 First, check if another offer is already accepted for this task
        if (offerRepo.existsByRegularTaskAndStatus(taskId, OfferStatus.ACCEPTED)) {
            return false;
        }

        return offerRepo.findById(offerId).map(offer -> {
            if (!offer.getRegularTask().equals(taskId)) {
                return false;
            }

            if (offer.getStatus() == OfferStatus.ACCEPTED) {
                return false;
            }

            // ✅ Prevent runner from having multiple accepted offers
            boolean runnerHasAccepted = offerRepo.existsByRunnerIdAndStatus(offer.getRunnerId(), OfferStatus.ACCEPTED);
            if (runnerHasAccepted) {
                return false;
            }

            // 🟢 Accept this offer
            offer.setStatus(OfferStatus.ACCEPTED);
            offerRepo.save(offer);

            // ❌ Delete all other offers on the same task except this one
            offerRepo.deleteOtherOffersForTask(taskId, offer.getOfferId());

            return true;
        }).orElse(false);
    }

    public boolean acceptOffer(Long taskId, Long offerId, Long taskPosterId) {
        boolean dbSuccess = acceptOfferTransactional(taskId, offerId);
        if (!dbSuccess) return false;

    try { //Existence checks
        if (!userClient.existsById(taskPosterId)) {
            throw new RuntimeException("TaskPoster not found: " + taskPosterId);
        }
    }catch (Exception e){
        System.err.println("Failed to check if task poster exists: "+e.getMessage());
    }
        // ✅ Call external service after DB operations succeed
        try {
            Offer offer = offerRepo.findById(offerId).orElseThrow();
            taskClient.acceptRegularTaskOffer(taskId, taskPosterId, offer.getRunnerId(), offer.getAmount());
            return true;
        } catch (Exception e) {
            System.err.println("❌ Failed to update task status via taskClient: " + e.getMessage());
            // Optional: log this to DB, or retry later
            return false;
        }
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


    // Returns the number of offers placed for a task
    public long getOfferCountForTask(Long taskId) {
        return offerRepo.countByRegularTask(taskId);
    }

    // Returns true if this runner has placed an offer on the task
    public boolean hasRunnerOffered(Long runnerId, Long taskId) {
        return offerRepo.existsByRunnerIdAndRegularTask(runnerId, taskId);
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
