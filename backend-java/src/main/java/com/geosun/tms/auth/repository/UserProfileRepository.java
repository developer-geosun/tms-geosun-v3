package com.geosun.tms.auth.repository;

import com.geosun.tms.auth.domain.profile.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserProfileRepository extends JpaRepository<UserProfile, String> {}
