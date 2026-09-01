import { HttpClient, provideHttpClient, withInterceptors } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import {
  APP_CLIENT_HEADER_NAME,
  APP_CLIENT_HEADER_VALUE,
  appClientInterceptor
} from './app-client.interceptor';

describe('appClientInterceptor', () => {
  let http: HttpClient;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        provideHttpClient(withInterceptors([appClientInterceptor])),
        provideHttpClientTesting()
      ]
    });

    http = TestBed.inject(HttpClient);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('adds X-App-Client angular header', () => {
    http.post('/api/v1/auth/register', {}).subscribe();

    const request = httpMock.expectOne('/api/v1/auth/register');
    expect(request.request.headers.get(APP_CLIENT_HEADER_NAME)).toBe(APP_CLIENT_HEADER_VALUE);
    request.flush({});
  });
});
