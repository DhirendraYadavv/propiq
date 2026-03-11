package com.propiq.backend.service.impl;

import com.propiq.backend.dto.request.LoginRequest;
import com.propiq.backend.dto.request.RegisterRequest;
import com.propiq.backend.dto.response.AuthResponse;
import com.propiq.backend.entity.User;
import com.propiq.backend.enums.AuthProvider;
import com.propiq.backend.repository.UserRepository;
import com.propiq.backend.security.CustomUserDetails;
import com.propiq.backend.security.jwt.JwtTokenProvider;
import com.propiq.backend.service.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final AuthenticationManager authenticationManager;

    @Override
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered: " + request.getEmail());
        }

        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .role(request.getRole())
                .provider(AuthProvider.LOCAL)
                .emailVerified(false)
                .build();

        userRepository.save(user);
        log.info("New user registered: {}", user.getEmail());

        String accessToken = jwtTokenProvider.generateTokenFromEmail(user.getEmail());
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getEmail());

        return buildAuthResponse(user, accessToken, refreshToken);
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        String accessToken = jwtTokenProvider.generateToken(authentication);
        String refreshToken = jwtTokenProvider.generateRefreshToken(userDetails.getEmail());

        log.info("User logged in: {}", userDetails.getEmail());
        return buildAuthResponse(userDetails.getUser(), accessToken, refreshToken);
    }

    @Override
    public AuthResponse refreshToken(String refreshToken) {
        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new RuntimeException("Invalid refresh token");
        }
        String email = jwtTokenProvider.extractEmail(refreshToken);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        String newAccessToken = jwtTokenProvider.generateTokenFromEmail(email);
        String newRefreshToken = jwtTokenProvider.generateRefreshToken(email);

        return buildAuthResponse(user, newAccessToken, newRefreshToken);
    }

    private AuthResponse buildAuthResponse(User user, String accessToken, String refreshToken) {
        return AuthResponse.builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .role(user.getRole())
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }
}
