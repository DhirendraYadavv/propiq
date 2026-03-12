package com.propiq.backend.service.impl;

import com.propiq.backend.dto.request.LeaseRequest;
import com.propiq.backend.entity.Lease;
import com.propiq.backend.entity.Property;
import com.propiq.backend.entity.Tenant;
import com.propiq.backend.enums.LeaseStatus;
import com.propiq.backend.repository.LeaseRepository;
import com.propiq.backend.repository.PropertyRepository;
import com.propiq.backend.repository.TenantRepository;
import com.propiq.backend.service.LeaseService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class LeaseServiceImpl implements LeaseService {

    private final LeaseRepository leaseRepository;
    private final PropertyRepository propertyRepository;
    private final TenantRepository tenantRepository;

    @Override
    public Lease createLease(LeaseRequest req, String ownerEmail) {
        Property property = propertyRepository.findById(req.getPropertyId())
                .orElseThrow(() -> new RuntimeException("Property not found"));
        Tenant tenant = tenantRepository.findById(req.getTenantId())
                .orElseThrow(() -> new RuntimeException("Tenant not found"));
        property.setIsOccupied(true);
        propertyRepository.save(property);
        Lease lease = Lease.builder()
                .property(property).tenant(tenant)
                .startDate(req.getStartDate()).endDate(req.getEndDate())
                .monthlyRent(req.getMonthlyRent()).securityDeposit(req.getSecurityDeposit())
                .dueDay(req.getDueDay() != null ? req.getDueDay() : 5)
                .build();
        return leaseRepository.save(lease);
    }

    @Override
    public List<Lease> getMyLeases(String ownerEmail) {
        return leaseRepository.findByPropertyOwnerId(
                propertyRepository.findAll().stream()
                        .filter(p -> p.getOwner().getEmail().equals(ownerEmail))
                        .findFirst().map(p -> p.getOwner().getId()).orElse(-1L));
    }

    @Override
    public Lease getLease(Long id, String ownerEmail) {
        return leaseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Lease not found"));
    }

    @Override
    @Scheduled(cron = "0 0 9 * * *")
    public void checkExpiringLeases() {
        LocalDate today = LocalDate.now();
        LocalDate thirtyDaysLater = today.plusDays(30);
        List<Lease> expiring = leaseRepository.findExpiringLeases(
                LeaseStatus.ACTIVE, today, thirtyDaysLater);
        for (Lease lease : expiring) {
            log.warn("LEASE EXPIRY ALERT: Lease ID {} for property '{}' expires on {}",
                    lease.getId(), lease.getProperty().getName(), lease.getEndDate());
            lease.setAlertSent(true);
            leaseRepository.save(lease);
        }
        log.info("Lease expiry check done. {} leases expiring soon.", expiring.size());
    }
}