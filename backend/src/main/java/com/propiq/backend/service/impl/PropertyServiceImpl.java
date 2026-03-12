package com.propiq.backend.service.impl;

import com.propiq.backend.dto.request.PropertyRequest;
import com.propiq.backend.entity.Property;
import com.propiq.backend.entity.User;
import com.propiq.backend.repository.PropertyRepository;
import com.propiq.backend.repository.UserRepository;
import com.propiq.backend.service.PropertyService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PropertyServiceImpl implements PropertyService {

    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;

    private User getOwner(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Override
    public Property createProperty(PropertyRequest req, String ownerEmail) {
        User owner = getOwner(ownerEmail);
        Property property = Property.builder()
                .owner(owner).name(req.getName()).address(req.getAddress())
                .city(req.getCity()).state(req.getState()).type(req.getType())
                .monthlyRent(req.getMonthlyRent()).securityDeposit(req.getSecurityDeposit())
                .description(req.getDescription()).build();
        return propertyRepository.save(property);
    }

    @Override
    public Property updateProperty(Long id, PropertyRequest req, String ownerEmail) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Property not found"));
        if (!property.getOwner().getEmail().equals(ownerEmail))
            throw new AccessDeniedException("Not your property");
        property.setName(req.getName()); property.setAddress(req.getAddress());
        property.setCity(req.getCity()); property.setState(req.getState());
        property.setType(req.getType()); property.setMonthlyRent(req.getMonthlyRent());
        property.setSecurityDeposit(req.getSecurityDeposit());
        property.setDescription(req.getDescription());
        return propertyRepository.save(property);
    }

    @Override
    public void deleteProperty(Long id, String ownerEmail) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Property not found"));
        if (!property.getOwner().getEmail().equals(ownerEmail))
            throw new AccessDeniedException("Not your property");
        propertyRepository.delete(property);
    }

    @Override
    public List<Property> getMyProperties(String ownerEmail) {
        User owner = getOwner(ownerEmail);
        return propertyRepository.findByOwnerId(owner.getId());
    }

    @Override
    public Property getProperty(Long id, String ownerEmail) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Property not found"));
        if (!property.getOwner().getEmail().equals(ownerEmail))
            throw new AccessDeniedException("Not your property");
        return property;
    }
}