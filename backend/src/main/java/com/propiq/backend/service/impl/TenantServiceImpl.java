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

    private String maskAadhaar(String aadhaar) {
        if (aadhaar == null || aadhaar.length() < 4) return aadhaar;
        return "XXXX-XXXX-" + aadhaar.substring(aadhaar.length() - 4);
    }

    @Override
    public Tenant createTenant(TenantRequest req, String ownerEmail) {
        User owner = getOwner(ownerEmail);
        Tenant tenant = Tenant.builder()
                .owner(owner).name(req.getName()).email(req.getEmail())
                .phone(req.getPhone()).aadhaarNumber(req.getAadhaarNumber())
                .panNumber(req.getPanNumber()).emergencyContact(req.getEmergencyContact())
                .build();
        Tenant saved = tenantRepository.save(tenant);
        saved.setAadhaarNumber(maskAadhaar(saved.getAadhaarNumber()));
        return saved;
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
        Tenant saved = tenantRepository.save(tenant);
        saved.setAadhaarNumber(maskAadhaar(saved.getAadhaarNumber()));
        return saved;
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
        List<Tenant> tenants = tenantRepository.findByOwnerId(owner.getId());
        tenants.forEach(t -> t.setAadhaarNumber(maskAadhaar(t.getAadhaarNumber())));
        return tenants;
    }

    @Override
    public Tenant getTenant(Long id, String ownerEmail) {
        Tenant tenant = tenantRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tenant not found"));
        if (!tenant.getOwner().getEmail().equals(ownerEmail))
            throw new AccessDeniedException("Not your tenant");
        tenant.setAadhaarNumber(maskAadhaar(tenant.getAadhaarNumber()));
        return tenant;
    }
}
