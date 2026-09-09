package com.geosun.tms.chatbot.repository;

import com.geosun.tms.chatbot.domain.BotLinkCode;
import com.geosun.tms.chatbot.domain.ChatbotChannel;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BotLinkCodeRepository extends JpaRepository<BotLinkCode, String> {

  Optional<BotLinkCode> findByCode(String code);

  boolean existsByCode(String code);

  Optional<BotLinkCode> findFirstByUserIdAndChannelOrderByCreatedAtDesc(
      String userId, ChatbotChannel channel);
}
