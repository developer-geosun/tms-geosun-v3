package com.geosun.tms.chatbot.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import org.hibernate.annotations.CreationTimestamp;

/** Журнал вхідних/вихідних повідомлень чат-бота. */
@Entity
@Table(name = "bot_message_log")
public class BotMessageLog {

  @Id
  @Column(name = "id", nullable = false, updatable = false, length = 36)
  private String id;

  @Enumerated(EnumType.STRING)
  @Column(name = "direction", nullable = false, length = 8)
  private BotMessageDirection direction;

  @Enumerated(EnumType.STRING)
  @Column(name = "channel", nullable = false, length = 16)
  private ChatbotChannel channel;

  @Column(name = "identity_id", length = 36)
  private String identityId;

  @Column(name = "user_id", length = 36)
  private String userId;

  @Column(name = "event_type", nullable = false, length = 64)
  private String eventType;

  @Column(name = "idempotency_key", length = 190)
  private String idempotencyKey;

  @Enumerated(EnumType.STRING)
  @Column(name = "status", nullable = false, length = 16)
  private BotMessageStatus status;

  @Column(name = "payload_preview", length = 512)
  private String payloadPreview;

  @Column(name = "provider_error", length = 256)
  private String providerError;

  @Column(name = "attempt_count", nullable = false)
  private int attemptCount;

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private Instant createdAt;

  @Column(name = "sent_at")
  private Instant sentAt;

  @PrePersist
  void assignId() {
    if (id == null) {
      id = UUID.randomUUID().toString();
    }
  }

  public String getId() {
    return id;
  }

  public void setId(String id) {
    this.id = id;
  }

  public BotMessageDirection getDirection() {
    return direction;
  }

  public void setDirection(BotMessageDirection direction) {
    this.direction = direction;
  }

  public ChatbotChannel getChannel() {
    return channel;
  }

  public void setChannel(ChatbotChannel channel) {
    this.channel = channel;
  }

  public String getIdentityId() {
    return identityId;
  }

  public void setIdentityId(String identityId) {
    this.identityId = identityId;
  }

  public String getUserId() {
    return userId;
  }

  public void setUserId(String userId) {
    this.userId = userId;
  }

  public String getEventType() {
    return eventType;
  }

  public void setEventType(String eventType) {
    this.eventType = eventType;
  }

  public String getIdempotencyKey() {
    return idempotencyKey;
  }

  public void setIdempotencyKey(String idempotencyKey) {
    this.idempotencyKey = idempotencyKey;
  }

  public BotMessageStatus getStatus() {
    return status;
  }

  public void setStatus(BotMessageStatus status) {
    this.status = status;
  }

  public String getPayloadPreview() {
    return payloadPreview;
  }

  public void setPayloadPreview(String payloadPreview) {
    this.payloadPreview = payloadPreview;
  }

  public String getProviderError() {
    return providerError;
  }

  public void setProviderError(String providerError) {
    this.providerError = providerError;
  }

  public int getAttemptCount() {
    return attemptCount;
  }

  public void setAttemptCount(int attemptCount) {
    this.attemptCount = attemptCount;
  }

  public Instant getCreatedAt() {
    return createdAt;
  }

  public Instant getSentAt() {
    return sentAt;
  }

  public void setSentAt(Instant sentAt) {
    this.sentAt = sentAt;
  }
}
