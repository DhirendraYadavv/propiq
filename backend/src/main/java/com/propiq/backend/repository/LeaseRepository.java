package com.propiq.backend.repository;

import com.propiq.backend.entity.Lease;
import com.propiq.backend.enums.LeaseStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface LeaseRepository extends JpaRepository<Lease, Long> {
    List<Lease> findByPropertyOwnerId(Long ownerId);

    @Query("SELECT l FROM Lease l WHERE l.status = :status AND l.endDate BETWEEN :start AND :end AND l.alertSent = false")
    List<Lease> findExpiringLeases(LeaseStatus status, LocalDate start, LocalDate end);
}