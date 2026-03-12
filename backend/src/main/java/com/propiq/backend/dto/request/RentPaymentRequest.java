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