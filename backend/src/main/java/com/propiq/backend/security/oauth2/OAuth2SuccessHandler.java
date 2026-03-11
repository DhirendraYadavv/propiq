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
