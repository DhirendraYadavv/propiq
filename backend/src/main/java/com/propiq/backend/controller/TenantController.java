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