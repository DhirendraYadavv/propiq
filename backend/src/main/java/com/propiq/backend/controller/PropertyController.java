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