package com.geosun.tms.auth.domain.profile;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/** Телефон контакту профілю користувача. */
@Entity
@Table(name = "user_contact_phones")
public class UserContactPhone {

  @Id
  @Column(name = "id", nullable = false, updatable = false, length = 36)
  private String id;

  @Column(name = "user_id", nullable = false, length = 36)
  private String userId;

  @Column(name = "phone", nullable = false, length = 32)
  private String phone;

  @Column(name = "sort_order", nullable = false)
  private int sortOrder;

  @Column(name = "is_primary", nullable = false)
  private boolean primary;

  @Column(name = "has_telegram", nullable = false)
  private boolean telegram;

  @Column(name = "has_whatsapp", nullable = false)
  private boolean whatsapp;

  @Column(name = "has_viber", nullable = false)
  private boolean viber;

  /** Чи підтверджено номер через месенджер (серверний прапорець). */
  @Column(name = "phone_verified", nullable = false)
  private boolean phoneVerified;

  @Column(name = "phone_verified_at")
  private Instant phoneVerifiedAt;

  /** Канал верифікації, напр. TELEGRAM. */
  @Column(name = "phone_verified_via", length = 16)
  private String phoneVerifiedVia;

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private Instant createdAt;

  @UpdateTimestamp
  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt;

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

  public String getUserId() {
    return userId;
  }

  public void setUserId(String userId) {
    this.userId = userId;
  }

  public String getPhone() {
    return phone;
  }

  public void setPhone(String phone) {
    this.phone = phone;
  }

  public int getSortOrder() {
    return sortOrder;
  }

  public void setSortOrder(int sortOrder) {
    this.sortOrder = sortOrder;
  }

  public boolean isPrimary() {
    return primary;
  }

  public void setPrimary(boolean primary) {
    this.primary = primary;
  }

  public boolean isTelegram() {
    return telegram;
  }

  public void setTelegram(boolean telegram) {
    this.telegram = telegram;
  }

  public boolean isWhatsapp() {
    return whatsapp;
  }

  public void setWhatsapp(boolean whatsapp) {
    this.whatsapp = whatsapp;
  }

  public boolean isViber() {
    return viber;
  }

  public void setViber(boolean viber) {
    this.viber = viber;
  }

  public boolean isPhoneVerified() {
    return phoneVerified;
  }

  public void setPhoneVerified(boolean phoneVerified) {
    this.phoneVerified = phoneVerified;
  }

  public Instant getPhoneVerifiedAt() {
    return phoneVerifiedAt;
  }

  public void setPhoneVerifiedAt(Instant phoneVerifiedAt) {
    this.phoneVerifiedAt = phoneVerifiedAt;
  }

  public String getPhoneVerifiedVia() {
    return phoneVerifiedVia;
  }

  public void setPhoneVerifiedVia(String phoneVerifiedVia) {
    this.phoneVerifiedVia = phoneVerifiedVia;
  }

  public Instant getCreatedAt() {
    return createdAt;
  }

  public Instant getUpdatedAt() {
    return updatedAt;
  }
}
