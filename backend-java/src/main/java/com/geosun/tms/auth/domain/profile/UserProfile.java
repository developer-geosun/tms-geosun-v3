package com.geosun.tms.auth.domain.profile;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/** Профіль облікового запису (1:1 з users), окрема таблиця. */
@Entity
@Table(name = "user_profiles")
public class UserProfile {

  @Id
  @Column(name = "user_id", nullable = false, updatable = false, length = 36)
  private String userId;

  @Column(name = "last_name", length = 128)
  private String lastName;

  @Column(name = "first_name", length = 128)
  private String firstName;

  @Column(name = "patronymic", length = 128)
  private String patronymic;

  @Enumerated(EnumType.STRING)
  @Column(name = "person_type", length = 32)
  private PersonType personType;

  @Column(name = "legal_entity_edrpou", length = 10)
  private String legalEntityEdrpou;

  @Column(name = "contact_via_email", nullable = false)
  private boolean contactViaEmail;

  @Column(name = "contact_via_phone", nullable = false)
  private boolean contactViaPhone;

  @Column(name = "contact_via_messengers", nullable = false)
  private boolean contactViaMessengers;

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private Instant createdAt;

  @UpdateTimestamp
  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt;

  public String getUserId() {
    return userId;
  }

  public void setUserId(String userId) {
    this.userId = userId;
  }

  public String getLastName() {
    return lastName;
  }

  public void setLastName(String lastName) {
    this.lastName = lastName;
  }

  public String getFirstName() {
    return firstName;
  }

  public void setFirstName(String firstName) {
    this.firstName = firstName;
  }

  public String getPatronymic() {
    return patronymic;
  }

  public void setPatronymic(String patronymic) {
    this.patronymic = patronymic;
  }

  public PersonType getPersonType() {
    return personType;
  }

  public void setPersonType(PersonType personType) {
    this.personType = personType;
  }

  public String getLegalEntityEdrpou() {
    return legalEntityEdrpou;
  }

  public void setLegalEntityEdrpou(String legalEntityEdrpou) {
    this.legalEntityEdrpou = legalEntityEdrpou;
  }

  public boolean isContactViaEmail() {
    return contactViaEmail;
  }

  public void setContactViaEmail(boolean contactViaEmail) {
    this.contactViaEmail = contactViaEmail;
  }

  public boolean isContactViaPhone() {
    return contactViaPhone;
  }

  public void setContactViaPhone(boolean contactViaPhone) {
    this.contactViaPhone = contactViaPhone;
  }

  public boolean isContactViaMessengers() {
    return contactViaMessengers;
  }

  public void setContactViaMessengers(boolean contactViaMessengers) {
    this.contactViaMessengers = contactViaMessengers;
  }

  public Instant getCreatedAt() {
    return createdAt;
  }

  public Instant getUpdatedAt() {
    return updatedAt;
  }
}
