package com.geosun.tms.auth.dto.request;

import com.geosun.tms.auth.domain.user.Role;

/** Параметри списку користувачів для ADMIN/MANAGER. */
public record AdminUserListQuery(
    String email,
    String name,
    Role role,
    Boolean active,
    Boolean deleted,
    String sort,
    String order,
    int page,
    int size) {}
