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