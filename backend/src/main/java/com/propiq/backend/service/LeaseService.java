package com.propiq.backend.service;

import com.propiq.backend.dto.request.LeaseRequest;
import com.propiq.backend.entity.Lease;
import java.util.List;

public interface LeaseService {
    Lease createLease(LeaseRequest request, String ownerEmail);
    List<Lease> getMyLeases(String ownerEmail);
    Lease getLease(Long id, String ownerEmail);
    void checkExpiringLeases();
}