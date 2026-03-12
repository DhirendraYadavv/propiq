package com.propiq.backend.service;

import com.propiq.backend.dto.request.PropertyRequest;
import com.propiq.backend.entity.Property;
import java.util.List;

public interface PropertyService {
    Property createProperty(PropertyRequest request, String ownerEmail);
    Property updateProperty(Long id, PropertyRequest request, String ownerEmail);
    void deleteProperty(Long id, String ownerEmail);
    List<Property> getMyProperties(String ownerEmail);
    Property getProperty(Long id, String ownerEmail);
}