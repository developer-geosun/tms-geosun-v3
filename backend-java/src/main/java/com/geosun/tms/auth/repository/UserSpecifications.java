package com.geosun.tms.auth.repository;

import com.geosun.tms.auth.domain.profile.UserProfile;
import com.geosun.tms.auth.domain.user.Role;
import com.geosun.tms.auth.domain.user.User;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.util.StringUtils;

/** Фільтри списку користувачів для ADMIN/MANAGER. */
public final class UserSpecifications {

  private UserSpecifications() {}

  public static Specification<User> adminFilter(
      String email, String name, Role role, Boolean active, Boolean deleted) {
    return Specification.where(emailContains(email))
        .and(nameContains(name))
        .and(hasRole(role))
        .and(hasActive(active))
        .and(hasDeleted(deleted));
  }

  private static Specification<User> emailContains(String email) {
    return (root, query, cb) -> {
      if (!StringUtils.hasText(email)) {
        return cb.conjunction();
      }
      return cb.like(cb.lower(root.get("email")), "%" + email.trim().toLowerCase() + "%");
    };
  }

  /** Пошук contains по прізвищу/імені в user_profiles (EXISTS subquery). */
  private static Specification<User> nameContains(String name) {
    return (root, query, cb) -> {
      if (!StringUtils.hasText(name) || query == null) {
        return cb.conjunction();
      }
      String pattern = "%" + name.trim().toLowerCase() + "%";
      Subquery<String> subquery = query.subquery(String.class);
      Root<UserProfile> profile = subquery.from(UserProfile.class);
      subquery
          .select(profile.get("userId"))
          .where(
              cb.equal(profile.get("userId"), root.get("id")),
              cb.or(
                  cb.like(cb.lower(cb.coalesce(profile.get("lastName"), "")), pattern),
                  cb.like(cb.lower(cb.coalesce(profile.get("firstName"), "")), pattern)));
      return cb.exists(subquery);
    };
  }

  private static Specification<User> hasRole(Role role) {
    return (root, query, cb) -> role == null ? cb.conjunction() : cb.equal(root.get("role"), role);
  }

  private static Specification<User> hasActive(Boolean active) {
    return (root, query, cb) ->
        active == null ? cb.conjunction() : cb.equal(root.get("active"), active);
  }

  private static Specification<User> hasDeleted(Boolean deleted) {
    return (root, query, cb) ->
        deleted == null ? cb.conjunction() : cb.equal(root.get("deleted"), deleted);
  }
}
