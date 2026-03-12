package com.propiq.backend.repository;

import com.propiq.backend.entity.RentPayment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface RentPaymentRepository extends JpaRepository<RentPayment, Long> {
    List<RentPayment> findByLeaseId(Long leaseId);
    boolean existsByLeaseIdAndMonthYear(Long leaseId, String monthYear);
}