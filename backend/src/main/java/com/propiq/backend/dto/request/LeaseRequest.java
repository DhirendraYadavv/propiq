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