package com.gigs.task_service.repository;

import com.gigs.task_service.model.EventStaffingTask;
import com.gigs.task_service.model.RegularTask;
import com.gigs.task_service.model.Task;
import com.gigs.task_service.model.TaskStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface TaskRepository extends JpaRepository<Task,Long> {
    List<Task> findByTaskPoster(Long taskPoster);

    long countByTaskPosterAndStatus(Long taskPoster, TaskStatus status);

    @Query("""
      SELECT t
      FROM Task t
      WHERE TYPE(t) = RegularTask
        AND t.taskPoster = :poster
        AND t.status     = :status
    """)
    List<RegularTask> findRegularTasksByPosterAndStatus(
            @Param("poster") Long poster,
            @Param("status") TaskStatus status
    );

    @Query("""
      SELECT t
      FROM Task t
      WHERE TYPE(t) = EventStaffingTask
        AND t.taskPoster = :poster
        AND t.status     = :status
    """)
    List<EventStaffingTask> findEventTasksByPosterAndStatus(
            @Param("poster") Long poster,
            @Param("status") TaskStatus status
    );


// !!!!!DEH el regular task bs mmkn ast5dmha b3dain!!!!!
//    @Query("""
//        SELECT rt
//        FROM RegularTask rt
//        WHERE rt.status = :status
//          AND (6371 * acos(
//                cos(radians(:lat))
//              * cos(radians(rt.latitude))
//              * cos(radians(rt.longitude) - radians(:lon))
//              + sin(radians(:lat))
//              * sin(radians(rt.latitude))
//            )) <= :radius
//    """)
//    List<RegularTask> findNearbyByStatus(
//            @Param("status") TaskStatus status,
//            @Param("lat")    double lat,
//            @Param("lon")    double lon,
//            @Param("radius") double radius
//    );

    @Query("""
        SELECT t
        FROM Task t
        WHERE t.status = :status
          AND t.taskPoster <> :excludePosterId
          AND (6371 * acos(
                cos(radians(:lat)) 
              * cos(radians(t.latitude)) 
              * cos(radians(t.longitude) - radians(:lon)) 
              + sin(radians(:lat)) 
              * sin(radians(t.latitude))
            )) <= :radius
    """)
    List<Task> findNearbyByStatusExcludingPoster(
            @Param("status")           TaskStatus status,
            @Param("lat")              double lat,
            @Param("lon")              double lon,
            @Param("radius")           double radius,
            @Param("excludePosterId")  Long excludePosterId
    );


    List<Task> findByTaskPosterAndStatus(Long taskPoster, TaskStatus status);

}
