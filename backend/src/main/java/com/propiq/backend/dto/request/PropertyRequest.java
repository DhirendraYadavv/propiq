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