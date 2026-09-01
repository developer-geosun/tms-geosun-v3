import { HttpInterceptorFn } from '@angular/common/http';

/** Ідентифікатор Angular-клієнта для посилань у листах (X-App-Client). */
export const APP_CLIENT_HEADER_NAME = 'X-App-Client';
export const APP_CLIENT_HEADER_VALUE = 'angular';

/**
 * Додає X-App-Client, щоб backend зібрав посилання верифікації / скидання пароля на Angular.
 */
export const appClientInterceptor: HttpInterceptorFn = (request, next) => {
  if (request.headers.has(APP_CLIENT_HEADER_NAME)) {
    return next(request);
  }

  return next(
    request.clone({
      setHeaders: {
        [APP_CLIENT_HEADER_NAME]: APP_CLIENT_HEADER_VALUE
      }
    })
  );
};
