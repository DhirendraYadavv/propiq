package com.propiq.backend.repository;

import com.propiq.backend.entity.Tenant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface TenantRepository extends JpaRepository<Tenant, Long> {
    List<Tenant> findByOwnerId(Long ownerId);
    Optional<Tenant> findByEmail(String email);
}