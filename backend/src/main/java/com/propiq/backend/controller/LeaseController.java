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