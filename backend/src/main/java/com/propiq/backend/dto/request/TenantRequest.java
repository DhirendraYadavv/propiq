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