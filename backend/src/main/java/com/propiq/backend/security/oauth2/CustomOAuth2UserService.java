package com.propiq.backend.security.oauth2;

import com.propiq.backend.entity.User;
import com.propiq.backend.enums.AuthProvider;
import com.propiq.backend.enums.Role;
import com.propiq.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final UserRepository userRepository;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        GoogleOAuth2UserInfo userInfo = new GoogleOAuth2UserInfo(oAuth2User.getAttributes());

        User user = userRepository.findByEmail(userInfo.getEmail()).orElseGet(() ->
            userRepository.save(User.builder()
                .email(userInfo.getEmail())
                .name(userInfo.getName())
                .profilePictureUrl(userInfo.getImageUrl())
                .provider(AuthProvider.GOOGLE)
                .providerId(userInfo.getId())
                .role(Role.OWNER)
                .emailVerified(true)
                .build())
        );

        return new OAuth2UserPrincipal(user, oAuth2User.getAttributes());
    }
}