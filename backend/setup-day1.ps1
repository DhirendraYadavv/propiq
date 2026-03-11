# PropIQ Day 1 - Auto Setup Script
# Run this from: C:\Users\User\propiq\backend
# Command: powershell -ExecutionPolicy Bypass -File setup-day1.ps1

$base = "src\main\java\com\propiq\backend"

Write-Host "Creating PropIQ Day 1 files..." -ForegroundColor Cyan

# ─── application.yml ───
@'
server:
  port: 8080

spring:
  application:
    name: propiq-backend

  datasource:
    url: jdbc:postgresql://localhost:5432/propiq
    username: user
    password: password
    driver-class-name: org.postgresql.Driver

  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true

  security:
    oauth2:
      client:
        registration:
          google:
            client-id: ${GOOGLE_CLIENT_ID:your-google-client-id}
            client-secret: ${GOOGLE_CLIENT_SECRET:your-google-client-secret}
            scope:
              - email
              - profile

app:
  jwt:
    secret: 404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
    expiration-ms: 86400000
    refresh-expiration-ms: 604800000

springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html

logging:
  level:
    com.propiq: DEBUG
    org.springframework.security: DEBUG
'@ | Set-Content "src\main\resources\application.yml" -Encoding UTF8

if (Test-Path "src\main\resources\application.properties") {
    Remove-Item "src\main\resources\application.properties"
}
Write-Host "  [OK] application.yml" -ForegroundColor Green

# ─── BackendApplication.java ───
@'
package com.propiq.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableJpaAuditing
@EnableScheduling
public class BackendApplication {
    public static void main(String[] args) {
        SpringApplication.run(BackendApplication.class, args);
    }
}
'@ | Set-Content "$base\BackendApplication.java" -Encoding UTF8
Write-Host "  [OK] BackendApplication.java" -ForegroundColor Green

# ─── Role.java ───
@'
package com.propiq.backend.enums;

public enum Role {
    OWNER,
    TENANT,
    ADMIN
}
'@ | Set-Content "$base\enums\Role.java" -Encoding UTF8
Write-Host "  [OK] Role.java" -ForegroundColor Green

# ─── AuthProvider.java ───
@'
package com.propiq.backend.enums;

public enum AuthProvider {
    LOCAL,
    GOOGLE
}
'@ | Set-Content "$base\enums\AuthProvider.java" -Encoding UTF8
Write-Host "  [OK] AuthProvider.java" -ForegroundColor Green

# ─── User.java ───
@'
package com.propiq.backend.entity;

import com.propiq.backend.enums.AuthProvider;
import com.propiq.backend.enums.Role;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@EntityListeners(AuditingEntityListener.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "password_hash")
    private String passwordHash;

    @Column(nullable = false)
    private String name;

    @Column(name = "profile_picture_url")
    private String profilePictureUrl;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private AuthProvider provider = AuthProvider.LOCAL;

    @Column(name = "provider_id")
    private String providerId;

    @Column(name = "email_verified")
    @Builder.Default
    private Boolean emailVerified = false;

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
'@ | Set-Content "$base\entity\User.java" -Encoding UTF8
Write-Host "  [OK] User.java" -ForegroundColor Green

# ─── UserRepository.java ───
@'
package com.propiq.backend.repository;

import com.propiq.backend.entity.User;
import com.propiq.backend.enums.AuthProvider;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Boolean existsByEmail(String email);
    Optional<User> findByProviderAndProviderId(AuthProvider provider, String providerId);
}
'@ | Set-Content "$base\repository\UserRepository.java" -Encoding UTF8
Write-Host "  [OK] UserRepository.java" -ForegroundColor Green

# ─── JwtTokenProvider.java ───
@'
package com.propiq.backend.security.jwt;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.function.Function;

@Slf4j
@Component
public class JwtTokenProvider {

    @Value("${app.jwt.secret}")
    private String jwtSecret;

    @Value("${app.jwt.expiration-ms}")
    private long jwtExpirationMs;

    @Value("${app.jwt.refresh-expiration-ms}")
    private long refreshExpirationMs;

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes());
    }

    public String generateToken(Authentication authentication) {
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        return buildToken(userDetails.getUsername(), jwtExpirationMs);
    }

    public String generateTokenFromEmail(String email) {
        return buildToken(email, jwtExpirationMs);
    }

    public String generateRefreshToken(String email) {
        return buildToken(email, refreshExpirationMs);
    }

    private String buildToken(String subject, long expiration) {
        return Jwts.builder()
                .subject(subject)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getSigningKey())
                .compact();
    }

    public String extractEmail(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        return claimsResolver.apply(extractAllClaims(token));
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser().verifyWith(getSigningKey()).build().parseSignedClaims(token);
            return true;
        } catch (MalformedJwtException e) {
            log.error("Invalid JWT: {}", e.getMessage());
        } catch (ExpiredJwtException e) {
            log.error("Expired JWT: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            log.error("Unsupported JWT: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            log.error("Empty JWT: {}", e.getMessage());
        }
        return false;
    }
}
'@ | Set-Content "$base\security\jwt\JwtTokenProvider.java" -Encoding UTF8
Write-Host "  [OK] JwtTokenProvider.java" -ForegroundColor Green

# ─── JwtAuthenticationFilter.java ───
@'
package com.propiq.backend.security.jwt;

import com.propiq.backend.security.CustomUserDetailsService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final CustomUserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        try {
            String jwt = getJwtFromRequest(request);
            if (StringUtils.hasText(jwt) && jwtTokenProvider.validateToken(jwt)) {
                String email = jwtTokenProvider.extractEmail(jwt);
                UserDetails userDetails = userDetailsService.loadUserByUsername(email);
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception ex) {
            log.error("Could not set user authentication: {}", ex.getMessage());
        }
        filterChain.doFilter(request, response);
    }

    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
'@ | Set-Content "$base\security\jwt\JwtAuthenticationFilter.java" -Encoding UTF8
Write-Host "  [OK] JwtAuthenticationFilter.java" -ForegroundColor Green

# ─── CustomUserDetails.java ───
@'
package com.propiq.backend.security;

import com.propiq.backend.entity.User;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

@Getter
@AllArgsConstructor
public class CustomUserDetails implements UserDetails {

    private final User user;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + user.getRole().name()));
    }

    @Override
    public String getPassword() {
        return user.getPasswordHash();
    }

    @Override
    public String getUsername() {
        return user.getEmail();
    }

    public Long getId() {
        return user.getId();
    }

    public String getName() {
        return user.getName();
    }

    public String getEmail() {
        return user.getEmail();
    }
}
'@ | Set-Content "$base\security\CustomUserDetails.java" -Encoding UTF8
Write-Host "  [OK] CustomUserDetails.java" -ForegroundColor Green

# ─── CustomUserDetailsService.java ───
@'
package com.propiq.backend.security;

import com.propiq.backend.entity.User;
import com.propiq.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));
        return new CustomUserDetails(user);
    }
}
'@ | Set-Content "$base\security\CustomUserDetailsService.java" -Encoding UTF8
Write-Host "  [OK] CustomUserDetailsService.java" -ForegroundColor Green

# ─── GoogleOAuth2UserInfo.java ───
@'
package com.propiq.backend.security.oauth2;

import java.util.Map;

public class GoogleOAuth2UserInfo {

    private final Map<String, Object> attributes;

    public GoogleOAuth2UserInfo(Map<String, Object> attributes) {
        this.attributes = attributes;
    }

    public String getId() {
        return (String) attributes.get("sub");
    }

    public String getName() {
        return (String) attributes.get("name");
    }

    public String getEmail() {
        return (String) attributes.get("email");
    }

    public String getProfilePictureUrl() {
        return (String) attributes.get("picture");
    }
}
'@ | Set-Content "$base\security\oauth2\GoogleOAuth2UserInfo.java" -Encoding UTF8
Write-Host "  [OK] GoogleOAuth2UserInfo.java" -ForegroundColor Green

# ─── CustomOAuth2UserService.java ───
@'
package com.propiq.backend.security.oauth2;

import com.propiq.backend.entity.User;
import com.propiq.backend.enums.AuthProvider;
import com.propiq.backend.enums.Role;
import com.propiq.backend.repository.UserRepository;
import com.propiq.backend.security.CustomUserDetails;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final UserRepository userRepository;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        GoogleOAuth2UserInfo userInfo = new GoogleOAuth2UserInfo(oAuth2User.getAttributes());

        User user = userRepository.findByEmail(userInfo.getEmail())
                .map(existing -> updateExistingUser(existing, userInfo))
                .orElseGet(() -> registerNewUser(userInfo));

        return new CustomUserDetails(user);
    }

    private User registerNewUser(GoogleOAuth2UserInfo userInfo) {
        User user = User.builder()
                .email(userInfo.getEmail())
                .name(userInfo.getName())
                .profilePictureUrl(userInfo.getProfilePictureUrl())
                .provider(AuthProvider.GOOGLE)
                .providerId(userInfo.getId())
                .role(Role.OWNER)
                .emailVerified(true)
                .build();
        log.info("Registering new Google user: {}", userInfo.getEmail());
        return userRepository.save(user);
    }

    private User updateExistingUser(User user, GoogleOAuth2UserInfo userInfo) {
        user.setName(userInfo.getName());
        user.setProfilePictureUrl(userInfo.getProfilePictureUrl());
        return userRepository.save(user);
    }
}
'@ | Set-Content "$base\security\oauth2\CustomOAuth2UserService.java" -Encoding UTF8
Write-Host "  [OK] CustomOAuth2UserService.java" -ForegroundColor Green

# ─── OAuth2SuccessHandler.java ───
@'
package com.propiq.backend.security.oauth2;

import com.propiq.backend.security.CustomUserDetails;
import com.propiq.backend.security.jwt.JwtTokenProvider;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Slf4j
@Component
@RequiredArgsConstructor
public class OAuth2SuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final JwtTokenProvider jwtTokenProvider;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException {
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        String token = jwtTokenProvider.generateTokenFromEmail(userDetails.getEmail());
        String refreshToken = jwtTokenProvider.generateRefreshToken(userDetails.getEmail());
        log.info("OAuth2 login successful for: {}", userDetails.getEmail());
        String redirectUrl = "http://localhost:3000/oauth2/callback"
                + "?token=" + token
                + "&refreshToken=" + refreshToken;
        getRedirectStrategy().sendRedirect(request, response, redirectUrl);
    }
}
'@ | Set-Content "$base\security\oauth2\OAuth2SuccessHandler.java" -Encoding UTF8
Write-Host "  [OK] OAuth2SuccessHandler.java" -ForegroundColor Green

# ─── SecurityConfig.java ───
@'
package com.propiq.backend.config;

import com.propiq.backend.security.CustomUserDetailsService;
import com.propiq.backend.security.jwt.JwtAuthenticationFilter;
import com.propiq.backend.security.oauth2.CustomOAuth2UserService;
import com.propiq.backend.security.oauth2.OAuth2SuccessHandler;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final CustomUserDetailsService userDetailsService;
    private final CustomOAuth2UserService customOAuth2UserService;
    private final OAuth2SuccessHandler oAuth2SuccessHandler;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                    "/api/auth/**",
                    "/swagger-ui/**",
                    "/swagger-ui.html",
                    "/api-docs/**",
                    "/oauth2/**"
                ).permitAll()
                .anyRequest().authenticated()
            )
            .oauth2Login(oauth2 -> oauth2
                .userInfoEndpoint(u -> u.userService(customOAuth2UserService))
                .successHandler(oAuth2SuccessHandler)
            )
            .authenticationProvider(authenticationProvider())
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder());
        return provider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
'@ | Set-Content "$base\config\SecurityConfig.java" -Encoding UTF8
Write-Host "  [OK] SecurityConfig.java" -ForegroundColor Green

# ─── ApiResponse.java ───
@'
package com.propiq.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponse<T> {
    private boolean success;
    private String message;
    private T data;

    @Builder.Default
    private LocalDateTime timestamp = LocalDateTime.now();

    public static <T> ApiResponse<T> success(String message, T data) {
        return ApiResponse.<T>builder()
                .success(true)
                .message(message)
                .data(data)
                .build();
    }

    public static <T> ApiResponse<T> error(String message) {
        return ApiResponse.<T>builder()
                .success(false)
                .message(message)
                .build();
    }
}
'@ | Set-Content "$base\dto\response\ApiResponse.java" -Encoding UTF8
Write-Host "  [OK] ApiResponse.java" -ForegroundColor Green

# ─── AuthResponse.java ───
@'
package com.propiq.backend.dto.response;

import com.propiq.backend.enums.Role;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private Long id;
    private String name;
    private String email;
    private Role role;
    private String accessToken;
    private String refreshToken;
    @Builder.Default
    private String tokenType = "Bearer";
}
'@ | Set-Content "$base\dto\response\AuthResponse.java" -Encoding UTF8
Write-Host "  [OK] AuthResponse.java" -ForegroundColor Green

# ─── RegisterRequest.java ───
@'
package com.propiq.backend.dto.request;

import com.propiq.backend.enums.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {

    @NotBlank(message = "Name is required")
    private String name;

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;

    @NotNull(message = "Role is required")
    private Role role;
}
'@ | Set-Content "$base\dto\request\RegisterRequest.java" -Encoding UTF8
Write-Host "  [OK] RegisterRequest.java" -ForegroundColor Green

# ─── LoginRequest.java ───
@'
package com.propiq.backend.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Password is required")
    private String password;
}
'@ | Set-Content "$base\dto\request\LoginRequest.java" -Encoding UTF8
Write-Host "  [OK] LoginRequest.java" -ForegroundColor Green

# ─── AuthService.java ───
@'
package com.propiq.backend.service;

import com.propiq.backend.dto.request.LoginRequest;
import com.propiq.backend.dto.request.RegisterRequest;
import com.propiq.backend.dto.response.AuthResponse;

public interface AuthService {
    AuthResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
    AuthResponse refreshToken(String refreshToken);
}
'@ | Set-Content "$base\service\AuthService.java" -Encoding UTF8
Write-Host "  [OK] AuthService.java" -ForegroundColor Green

# ─── AuthServiceImpl.java ───
@'
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
'@ | Set-Content "$base\service\impl\AuthServiceImpl.java" -Encoding UTF8
Write-Host "  [OK] AuthServiceImpl.java" -ForegroundColor Green

# ─── AuthController.java ───
@'
package com.propiq.backend.controller;

import com.propiq.backend.dto.request.LoginRequest;
import com.propiq.backend.dto.request.RegisterRequest;
import com.propiq.backend.dto.response.ApiResponse;
import com.propiq.backend.dto.response.AuthResponse;
import com.propiq.backend.entity.User;
import com.propiq.backend.repository.UserRepository;
import com.propiq.backend.security.CustomUserDetails;
import com.propiq.backend.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Register, Login, Token refresh")
public class AuthController {

    private final AuthService authService;
    private final UserRepository userRepository;

    @PostMapping("/register")
    @Operation(summary = "Register a new user")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.ok(ApiResponse.success("Registered successfully", response));
    }

    @PostMapping("/login")
    @Operation(summary = "Login with email and password")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success("Login successful", response));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Refresh access token")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(@RequestParam String refreshToken) {
        AuthResponse response = authService.refreshToken(refreshToken);
        return ResponseEntity.ok(ApiResponse.success("Token refreshed", response));
    }

    @GetMapping("/me")
    @Operation(summary = "Get current user", security = @SecurityRequirement(name = "bearerAuth"))
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<User>> getCurrentUser(@AuthenticationPrincipal CustomUserDetails userDetails) {
        User user = userRepository.findByEmail(userDetails.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));
        return ResponseEntity.ok(ApiResponse.success("User fetched", user));
    }
}
'@ | Set-Content "$base\controller\AuthController.java" -Encoding UTF8
Write-Host "  [OK] AuthController.java" -ForegroundColor Green

# ─── GlobalExceptionHandler.java ───
@'
package com.propiq.backend.exception;

import com.propiq.backend.dto.response.ApiResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ApiResponse<Void>> handleRuntimeException(RuntimeException ex) {
        log.error("Runtime error: {}", ex.getMessage());
        return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
    }

    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ApiResponse<Void>> handleBadCredentials(BadCredentialsException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(ApiResponse.error("Invalid email or password"));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiResponse<Void>> handleAccessDenied(AccessDeniedException ex) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(ApiResponse.error("Access denied"));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Map<String, String>>> handleValidation(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String field = ((FieldError) error).getField();
            errors.put(field, error.getDefaultMessage());
        });
        return ResponseEntity.badRequest().body(ApiResponse.<Map<String, String>>builder()
                .success(false)
                .message("Validation failed")
                .data(errors)
                .build());
    }
}
'@ | Set-Content "$base\exception\GlobalExceptionHandler.java" -Encoding UTF8
Write-Host "  [OK] GlobalExceptionHandler.java" -ForegroundColor Green

# ─── OpenApiConfig.java ───
@'
package com.propiq.backend.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import org.springframework.context.annotation.Configuration;

@Configuration
@OpenAPIDefinition(info = @Info(
        title = "PropIQ API",
        version = "1.0",
        description = "Property Management SaaS for Indian Landlords"
))
@SecurityScheme(
        name = "bearerAuth",
        type = SecuritySchemeType.HTTP,
        scheme = "bearer",
        bearerFormat = "JWT"
)
public class OpenApiConfig {
}
'@ | Set-Content "$base\config\OpenApiConfig.java" -Encoding UTF8
Write-Host "  [OK] OpenApiConfig.java" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " All 17 Day 1 files created!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next: Run the app in IntelliJ" -ForegroundColor Yellow
Write-Host "Then open: http://localhost:8080/swagger-ui.html" -ForegroundColor Yellow
