package com.propiq.backend.service;

import com.propiq.backend.dto.request.LoginRequest;
import com.propiq.backend.dto.request.RegisterRequest;
import com.propiq.backend.dto.response.AuthResponse;

public interface AuthService {
    AuthResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
    AuthResponse refreshToken(String refreshToken);
}
