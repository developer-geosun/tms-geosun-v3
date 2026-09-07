package com.geosun.tms.auth.repository;

import com.geosun.tms.auth.domain.profile.UserContactPhone;
import java.util.Collection;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UserContactPhoneRepository extends JpaRepository<UserContactPhone, String> {

  List<UserContactPhone> findByUserIdOrderBySortOrderAsc(String userId);

  List<UserContactPhone> findByUserIdInOrderByUserIdAscSortOrderAsc(Collection<String> userIds);

  @Modifying(clearAutomatically = true, flushAutomatically = true)
  @Query("delete from UserContactPhone p where p.userId = :userId")
  void deleteAllByUserId(@Param("userId") String userId);
}
