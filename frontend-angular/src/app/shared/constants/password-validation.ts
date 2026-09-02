/** Мінімальні вимоги до пароля — узгоджено з backend RegisterRequest / ResetPasswordRequest. */
export const PASSWORD_MIN_LENGTH = 8;

export const PASSWORD_PATTERN = /^(?=.*[A-Za-z])(?=.*\d).{8,}$/;
