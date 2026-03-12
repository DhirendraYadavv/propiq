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