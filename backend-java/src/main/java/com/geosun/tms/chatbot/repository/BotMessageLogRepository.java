package com.geosun.tms.chatbot.repository;

import com.geosun.tms.chatbot.domain.BotMessageLog;
import java.time.Instant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BotMessageLogRepository extends JpaRepository<BotMessageLog, String> {

  boolean existsByIdempotencyKey(String idempotencyKey);

  @Modifying(clearAutomatically = true, flushAutomatically = true)
  @Query("delete from BotMessageLog m where m.createdAt < :cutoff")
  int deleteByCreatedAtBefore(@Param("cutoff") Instant cutoff);
}
