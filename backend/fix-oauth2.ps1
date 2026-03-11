$base = "src\main\java\com\propiq\backend\security\oauth2"

$oauth2Service = @'
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
'@

$oauth2Principal = @'
package com.propiq.backend.security.oauth2;

import com.propiq.backend.entity.User;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.core.user.OAuth2User;

import java.util.Collection;
import java.util.List;
import java.util.Map;

public class OAuth2UserPrincipal implements OAuth2User {

    private final User user;
    private final Map<String, Object> attributes;

    public OAuth2UserPrincipal(User user, Map<String, Object> attributes) {
        this.user = user;
        this.attributes = attributes;
    }

    @Override
    public Map<String, Object> getAttributes() { return attributes; }

    @Override
    public String getName() { return user.getEmail(); }

    public User getUser() { return user; }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + user.getRole().name()));
    }
}
'@

[System.IO.File]::WriteAllText("$base\CustomOAuth2UserService.java", $oauth2Service, [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText("$base\OAuth2UserPrincipal.java", $oauth2Principal, [System.Text.UTF8Encoding]::new($false))

Write-Host "Done! Both files written." -ForegroundColor Green
