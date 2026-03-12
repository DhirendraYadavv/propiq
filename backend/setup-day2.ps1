$base = "src\main\java\com\propiq\backend"

Write-Host "Creating Day 2 files..." -ForegroundColor Cyan

# ─── ENUMS ───────────────────────────────────────────────
$propertyType = @'
package com.propiq.backend.enums;

public enum PropertyType {
    APARTMENT, HOUSE, VILLA, COMMERCIAL, PG
}
'@

$leaseStatus = @'
package com.propiq.backend.enums;

public enum LeaseStatus {
    ACTIVE, EXPIRED, TERMINATED
}
'@

$rentStatus = @'
package com.propiq.backend.enums;

public enum RentStatus {
    PAID, PENDING, OVERDUE
}
'@

# ─── ENTITIES ────────────────────────────────────────────
$property = @'
package com.propiq.backend.entity;

import com.propiq.backend.enums.PropertyType;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "properties")
@EntityListeners(AuditingEntityListener.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Property {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String address;

    private String city;
    private String state;

    @Enumerated(EnumType.STRING)
    private PropertyType type;

    @Column(name = "monthly_rent", precision = 10, scale = 2)
    private BigDecimal monthlyRent;

    @Column(name = "security_deposit", precision = 10, scale = 2)
    private BigDecimal securityDeposit;

    @Column(name = "is_occupied")
    @Builder.Default
    private Boolean isOccupied = false;

    private String description;

    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
'@

$tenant = @'
package com.propiq.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import java.time.LocalDateTime;

@Entity
@Table(name = "tenants")
@EntityListeners(AuditingEntityListener.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Tenant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    private String phone;

    @Column(name = "aadhaar_number")
    private String aadhaarNumber;

    @Column(name = "pan_number")
    private String panNumber;

    @Column(name = "emergency_contact")
    private String emergencyContact;

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
'@

$lease = @'
package com.propiq.backend.entity;

import com.propiq.backend.enums.LeaseStatus;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "leases")
@EntityListeners(AuditingEntityListener.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Lease {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    private Property property;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tenant_id", nullable = false)
    private Tenant tenant;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDate endDate;

    @Column(name = "monthly_rent", precision = 10, scale = 2)
    private BigDecimal monthlyRent;

    @Column(name = "security_deposit", precision = 10, scale = 2)
    private BigDecimal securityDeposit;

    @Column(name = "due_day")
    @Builder.Default
    private Integer dueDay = 5;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private LeaseStatus status = LeaseStatus.ACTIVE;

    @Column(name = "alert_sent")
    @Builder.Default
    private Boolean alertSent = false;

    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
'@

$rentPayment = @'
package com.propiq.backend.entity;

import com.propiq.backend.enums.RentStatus;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "rent_payments")
@EntityListeners(AuditingEntityListener.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class RentPayment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lease_id", nullable = false)
    private Lease lease;

    @Column(name = "month_year", nullable = false)
    private String monthYear;

    @Column(name = "amount_due", precision = 10, scale = 2)
    private BigDecimal amountDue;

    @Column(name = "amount_paid", precision = 10, scale = 2)
    private BigDecimal amountPaid;

    @Column(name = "late_fee", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal lateFee = BigDecimal.ZERO;

    @Column(name = "tds_applicable")
    @Builder.Default
    private Boolean tdsApplicable = false;

    @Column(name = "tds_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal tdsAmount = BigDecimal.ZERO;

    @Column(name = "paid_date")
    private LocalDate paidDate;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private RentStatus status = RentStatus.PENDING;

    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
'@

# ─── REPOSITORIES ────────────────────────────────────────
$propertyRepo = @'
package com.propiq.backend.repository;

import com.propiq.backend.entity.Property;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface PropertyRepository extends JpaRepository<Property, Long> {
    List<Property> findByOwnerId(Long ownerId);
}
'@

$tenantRepo = @'
package com.propiq.backend.repository;

import com.propiq.backend.entity.Tenant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface TenantRepository extends JpaRepository<Tenant, Long> {
    List<Tenant> findByOwnerId(Long ownerId);
    Optional<Tenant> findByEmail(String email);
}
'@

$leaseRepo = @'
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
'@

$rentRepo = @'
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
'@

# ─── DTOs ────────────────────────────────────────────────
$propertyRequest = @'
package com.propiq.backend.dto.request;

import com.propiq.backend.enums.PropertyType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class PropertyRequest {
    @NotBlank private String name;
    @NotBlank private String address;
    private String city;
    private String state;
    @NotNull private PropertyType type;
    @NotNull private BigDecimal monthlyRent;
    private BigDecimal securityDeposit;
    private String description;
}
'@

$tenantRequest = @'
package com.propiq.backend.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TenantRequest {
    @NotBlank private String name;
    @NotBlank @Email private String email;
    private String phone;
    private String aadhaarNumber;
    private String panNumber;
    private String emergencyContact;
}
'@

$leaseRequest = @'
package com.propiq.backend.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class LeaseRequest {
    @NotNull private Long propertyId;
    @NotNull private Long tenantId;
    @NotNull private LocalDate startDate;
    @NotNull private LocalDate endDate;
    @NotNull private BigDecimal monthlyRent;
    private BigDecimal securityDeposit;
    private Integer dueDay;
}
'@

$rentRequest = @'
package com.propiq.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class RentPaymentRequest {
    @NotNull private Long leaseId;
    @NotBlank private String monthYear;
    @NotNull private BigDecimal amountPaid;
    private LocalDate paidDate;
}
'@

# ─── SERVICES ────────────────────────────────────────────
$propertyService = @'
package com.propiq.backend.service;

import com.propiq.backend.dto.request.PropertyRequest;
import com.propiq.backend.entity.Property;
import java.util.List;

public interface PropertyService {
    Property createProperty(PropertyRequest request, String ownerEmail);
    Property updateProperty(Long id, PropertyRequest request, String ownerEmail);
    void deleteProperty(Long id, String ownerEmail);
    List<Property> getMyProperties(String ownerEmail);
    Property getProperty(Long id, String ownerEmail);
}
'@

$tenantService = @'
package com.propiq.backend.service;

import com.propiq.backend.dto.request.TenantRequest;
import com.propiq.backend.entity.Tenant;
import java.util.List;

public interface TenantService {
    Tenant createTenant(TenantRequest request, String ownerEmail);
    Tenant updateTenant(Long id, TenantRequest request, String ownerEmail);
    void deleteTenant(Long id, String ownerEmail);
    List<Tenant> getMyTenants(String ownerEmail);
    Tenant getTenant(Long id, String ownerEmail);
}
'@

$leaseService = @'
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
'@

$rentService = @'
package com.propiq.backend.service;

import com.propiq.backend.dto.request.RentPaymentRequest;
import com.propiq.backend.entity.RentPayment;
import java.util.List;

public interface RentPaymentService {
    RentPayment recordPayment(RentPaymentRequest request, String ownerEmail);
    List<RentPayment> getPaymentsForLease(Long leaseId, String ownerEmail);
}
'@

# ─── SERVICE IMPLS ───────────────────────────────────────
$propertyServiceImpl = @'
package com.propiq.backend.service.impl;

import com.propiq.backend.dto.request.PropertyRequest;
import com.propiq.backend.entity.Property;
import com.propiq.backend.entity.User;
import com.propiq.backend.repository.PropertyRepository;
import com.propiq.backend.repository.UserRepository;
import com.propiq.backend.service.PropertyService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PropertyServiceImpl implements PropertyService {

    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;

    private User getOwner(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Override
    public Property createProperty(PropertyRequest req, String ownerEmail) {
        User owner = getOwner(ownerEmail);
        Property property = Property.builder()
                .owner(owner).name(req.getName()).address(req.getAddress())
                .city(req.getCity()).state(req.getState()).type(req.getType())
                .monthlyRent(req.getMonthlyRent()).securityDeposit(req.getSecurityDeposit())
                .description(req.getDescription()).build();
        return propertyRepository.save(property);
    }

    @Override
    public Property updateProperty(Long id, PropertyRequest req, String ownerEmail) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Property not found"));
        if (!property.getOwner().getEmail().equals(ownerEmail))
            throw new AccessDeniedException("Not your property");
        property.setName(req.getName()); property.setAddress(req.getAddress());
        property.setCity(req.getCity()); property.setState(req.getState());
        property.setType(req.getType()); property.setMonthlyRent(req.getMonthlyRent());
        property.setSecurityDeposit(req.getSecurityDeposit());
        property.setDescription(req.getDescription());
        return propertyRepository.save(property);
    }

    @Override
    public void deleteProperty(Long id, String ownerEmail) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Property not found"));
        if (!property.getOwner().getEmail().equals(ownerEmail))
            throw new AccessDeniedException("Not your property");
        propertyRepository.delete(property);
    }

    @Override
    public List<Property> getMyProperties(String ownerEmail) {
        User owner = getOwner(ownerEmail);
        return propertyRepository.findByOwnerId(owner.getId());
    }

    @Override
    public Property getProperty(Long id, String ownerEmail) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Property not found"));
        if (!property.getOwner().getEmail().equals(ownerEmail))
            throw new AccessDeniedException("Not your property");
        return property;
    }
}
'@

$tenantServiceImpl = @'
package com.propiq.backend.service.impl;

import com.propiq.backend.dto.request.TenantRequest;
import com.propiq.backend.entity.Tenant;
import com.propiq.backend.entity.User;
import com.propiq.backend.repository.TenantRepository;
import com.propiq.backend.repository.UserRepository;
import com.propiq.backend.service.TenantService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TenantServiceImpl implements TenantService {

    private final TenantRepository tenantRepository;
    private final UserRepository userRepository;

    private User getOwner(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Override
    public Tenant createTenant(TenantRequest req, String ownerEmail) {
        User owner = getOwner(ownerEmail);
        Tenant tenant = Tenant.builder()
                .owner(owner).name(req.getName()).email(req.getEmail())
                .phone(req.getPhone()).aadhaarNumber(req.getAadhaarNumber())
                .panNumber(req.getPanNumber()).emergencyContact(req.getEmergencyContact())
                .build();
        return tenantRepository.save(tenant);
    }

    @Override
    public Tenant updateTenant(Long id, TenantRequest req, String ownerEmail) {
        Tenant tenant = tenantRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tenant not found"));
        if (!tenant.getOwner().getEmail().equals(ownerEmail))
            throw new AccessDeniedException("Not your tenant");
        tenant.setName(req.getName()); tenant.setEmail(req.getEmail());
        tenant.setPhone(req.getPhone()); tenant.setAadhaarNumber(req.getAadhaarNumber());
        tenant.setPanNumber(req.getPanNumber()); tenant.setEmergencyContact(req.getEmergencyContact());
        return tenantRepository.save(tenant);
    }

    @Override
    public void deleteTenant(Long id, String ownerEmail) {
        Tenant tenant = tenantRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tenant not found"));
        if (!tenant.getOwner().getEmail().equals(ownerEmail))
            throw new AccessDeniedException("Not your tenant");
        tenantRepository.delete(tenant);
    }

    @Override
    public List<Tenant> getMyTenants(String ownerEmail) {
        User owner = getOwner(ownerEmail);
        return tenantRepository.findByOwnerId(owner.getId());
    }

    @Override
    public Tenant getTenant(Long id, String ownerEmail) {
        Tenant tenant = tenantRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tenant not found"));
        if (!tenant.getOwner().getEmail().equals(ownerEmail))
            throw new AccessDeniedException("Not your tenant");
        return tenant;
    }
}
'@

$leaseServiceImpl = @'
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
'@

$rentServiceImpl = @'
package com.propiq.backend.service.impl;

import com.propiq.backend.dto.request.RentPaymentRequest;
import com.propiq.backend.entity.Lease;
import com.propiq.backend.entity.RentPayment;
import com.propiq.backend.enums.RentStatus;
import com.propiq.backend.repository.LeaseRepository;
import com.propiq.backend.repository.RentPaymentRepository;
import com.propiq.backend.service.RentPaymentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class RentPaymentServiceImpl implements RentPaymentService {

    private final RentPaymentRepository rentPaymentRepository;
    private final LeaseRepository leaseRepository;

    private static final BigDecimal TDS_THRESHOLD = new BigDecimal("50000");
    private static final BigDecimal TDS_RATE = new BigDecimal("0.10");
    private static final BigDecimal LATE_FEE_PER_DAY = new BigDecimal("100");

    @Override
    public RentPayment recordPayment(RentPaymentRequest req, String ownerEmail) {
        Lease lease = leaseRepository.findById(req.getLeaseId())
                .orElseThrow(() -> new RuntimeException("Lease not found"));

        if (rentPaymentRepository.existsByLeaseIdAndMonthYear(req.getLeaseId(), req.getMonthYear()))
            throw new RuntimeException("Payment already recorded for " + req.getMonthYear());

        LocalDate paidDate = req.getPaidDate() != null ? req.getPaidDate() : LocalDate.now();
        BigDecimal amountPaid = req.getAmountPaid();
        BigDecimal lateFee = BigDecimal.ZERO;
        BigDecimal tdsAmount = BigDecimal.ZERO;
        boolean tdsApplicable = false;

        // Late fee calculation
        int dueDay = lease.getDueDay();
        if (paidDate.getDayOfMonth() > dueDay) {
            int daysLate = paidDate.getDayOfMonth() - dueDay;
            lateFee = LATE_FEE_PER_DAY.multiply(BigDecimal.valueOf(daysLate));
            log.info("Late fee applied: ₹{} ({} days late)", lateFee, daysLate);
        }

        // TDS calculation - Section 194-IB
        if (lease.getMonthlyRent().compareTo(TDS_THRESHOLD) > 0) {
            tdsApplicable = true;
            tdsAmount = amountPaid.multiply(TDS_RATE);
            log.warn("TDS ALERT: Rent ₹{} exceeds ₹50,000. TDS applicable: ₹{} (Section 194-IB)",
                    lease.getMonthlyRent(), tdsAmount);
        }

        RentPayment payment = RentPayment.builder()
                .lease(lease).monthYear(req.getMonthYear())
                .amountDue(lease.getMonthlyRent()).amountPaid(amountPaid)
                .lateFee(lateFee).tdsApplicable(tdsApplicable).tdsAmount(tdsAmount)
                .paidDate(paidDate).status(RentStatus.PAID)
                .build();

        return rentPaymentRepository.save(payment);
    }

    @Override
    public List<RentPayment> getPaymentsForLease(Long leaseId, String ownerEmail) {
        return rentPaymentRepository.findByLeaseId(leaseId);
    }
}
'@

# ─── CONTROLLERS ─────────────────────────────────────────
$propertyController = @'
package com.propiq.backend.controller;

import com.propiq.backend.dto.request.PropertyRequest;
import com.propiq.backend.dto.response.ApiResponse;
import com.propiq.backend.service.PropertyService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/properties")
@RequiredArgsConstructor
public class PropertyController {

    private final PropertyService propertyService;

    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody PropertyRequest request,
                                     @AuthenticationPrincipal UserDetails userDetails) {
        var property = propertyService.createProperty(request, userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Property created", property));
    }

    @GetMapping
    public ResponseEntity<?> getAll(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(ApiResponse.success("Properties fetched",
                propertyService.getMyProperties(userDetails.getUsername())));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getOne(@PathVariable Long id,
                                     @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(ApiResponse.success("Property fetched",
                propertyService.getProperty(id, userDetails.getUsername())));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id,
                                     @Valid @RequestBody PropertyRequest request,
                                     @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(ApiResponse.success("Property updated",
                propertyService.updateProperty(id, request, userDetails.getUsername())));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id,
                                     @AuthenticationPrincipal UserDetails userDetails) {
        propertyService.deleteProperty(id, userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Property deleted", null));
    }
}
'@

$tenantController = @'
package com.propiq.backend.controller;

import com.propiq.backend.dto.request.TenantRequest;
import com.propiq.backend.dto.response.ApiResponse;
import com.propiq.backend.service.TenantService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/tenants")
@RequiredArgsConstructor
public class TenantController {

    private final TenantService tenantService;

    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody TenantRequest request,
                                     @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(ApiResponse.success("Tenant created",
                tenantService.createTenant(request, userDetails.getUsername())));
    }

    @GetMapping
    public ResponseEntity<?> getAll(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(ApiResponse.success("Tenants fetched",
                tenantService.getMyTenants(userDetails.getUsername())));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getOne(@PathVariable Long id,
                                     @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(ApiResponse.success("Tenant fetched",
                tenantService.getTenant(id, userDetails.getUsername())));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id,
                                     @Valid @RequestBody TenantRequest request,
                                     @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(ApiResponse.success("Tenant updated",
                tenantService.updateTenant(id, request, userDetails.getUsername())));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id,
                                     @AuthenticationPrincipal UserDetails userDetails) {
        tenantService.deleteTenant(id, userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Tenant deleted", null));
    }
}
'@

$leaseController = @'
package com.propiq.backend.controller;

import com.propiq.backend.dto.request.LeaseRequest;
import com.propiq.backend.dto.response.ApiResponse;
import com.propiq.backend.service.LeaseService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/leases")
@RequiredArgsConstructor
public class LeaseController {

    private final LeaseService leaseService;

    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody LeaseRequest request,
                                     @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(ApiResponse.success("Lease created",
                leaseService.createLease(request, userDetails.getUsername())));
    }

    @GetMapping
    public ResponseEntity<?> getAll(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(ApiResponse.success("Leases fetched",
                leaseService.getMyLeases(userDetails.getUsername())));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getOne(@PathVariable Long id,
                                     @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(ApiResponse.success("Lease fetched",
                leaseService.getLease(id, userDetails.getUsername())));
    }
}
'@

$rentController = @'
package com.propiq.backend.controller;

import com.propiq.backend.dto.request.RentPaymentRequest;
import com.propiq.backend.dto.response.ApiResponse;
import com.propiq.backend.service.RentPaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/rent")
@RequiredArgsConstructor
public class RentPaymentController {

    private final RentPaymentService rentPaymentService;

    @PostMapping("/pay")
    public ResponseEntity<?> recordPayment(@Valid @RequestBody RentPaymentRequest request,
                                            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(ApiResponse.success("Payment recorded",
                rentPaymentService.recordPayment(request, userDetails.getUsername())));
    }

    @GetMapping("/lease/{leaseId}")
    public ResponseEntity<?> getPayments(@PathVariable Long leaseId,
                                          @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(ApiResponse.success("Payments fetched",
                rentPaymentService.getPaymentsForLease(leaseId, userDetails.getUsername())));
    }
}
'@

# ─── WRITE ALL FILES ─────────────────────────────────────
$files = @{
    "$base\enums\PropertyType.java" = $propertyType
    "$base\enums\LeaseStatus.java" = $leaseStatus
    "$base\enums\RentStatus.java" = $rentStatus
    "$base\entity\Property.java" = $property
    "$base\entity\Tenant.java" = $tenant
    "$base\entity\Lease.java" = $lease
    "$base\entity\RentPayment.java" = $rentPayment
    "$base\repository\PropertyRepository.java" = $propertyRepo
    "$base\repository\TenantRepository.java" = $tenantRepo
    "$base\repository\LeaseRepository.java" = $leaseRepo
    "$base\repository\RentPaymentRepository.java" = $rentRepo
    "$base\dto\request\PropertyRequest.java" = $propertyRequest
    "$base\dto\request\TenantRequest.java" = $tenantRequest
    "$base\dto\request\LeaseRequest.java" = $leaseRequest
    "$base\dto\request\RentPaymentRequest.java" = $rentRequest
    "$base\service\PropertyService.java" = $propertyService
    "$base\service\TenantService.java" = $tenantService
    "$base\service\LeaseService.java" = $leaseService
    "$base\service\RentPaymentService.java" = $rentService
    "$base\service\impl\PropertyServiceImpl.java" = $propertyServiceImpl
    "$base\service\impl\TenantServiceImpl.java" = $tenantServiceImpl
    "$base\service\impl\LeaseServiceImpl.java" = $leaseServiceImpl
    "$base\service\impl\RentPaymentServiceImpl.java" = $rentServiceImpl
    "$base\controller\PropertyController.java" = $propertyController
    "$base\controller\TenantController.java" = $tenantController
    "$base\controller\LeaseController.java" = $leaseController
    "$base\controller\RentPaymentController.java" = $rentController
}

foreach ($path in $files.Keys) {
    [System.IO.File]::WriteAllText($path, $files[$path], [System.Text.UTF8Encoding]::new($false))
    Write-Host "  [OK] $($path.Split('\')[-1])" -ForegroundColor Green
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " All 28 Day 2 files created!" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Next: Restart the app in IntelliJ" -ForegroundColor Yellow
