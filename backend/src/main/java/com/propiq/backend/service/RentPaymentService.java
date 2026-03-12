package com.propiq.backend.service;

import com.propiq.backend.dto.request.RentPaymentRequest;
import com.propiq.backend.entity.RentPayment;
import java.util.List;

public interface RentPaymentService {
    RentPayment recordPayment(RentPaymentRequest request, String ownerEmail);
    List<RentPayment> getPaymentsForLease(Long leaseId, String ownerEmail);
}