import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { BackendApiService } from './backend-api.service';
import { UserProfileApiService } from './user-profile-api.service';

describe('UserProfileApiService', () => {
  let service: UserProfileApiService;
  let httpMock: HttpTestingController;
  let backendApi: BackendApiService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()]
    });
    service = TestBed.inject(UserProfileApiService);
    httpMock = TestBed.inject(HttpTestingController);
    backendApi = TestBed.inject(BackendApiService);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('gets own profile via GET /users/me/profile', async () => {
    const pending = service.getMine();
    const request = httpMock.expectOne(backendApi.myProfile);
    expect(request.request.method).toBe('GET');
    request.flush({
      lastName: null,
      firstName: null,
      patronymic: null,
      personType: null,
      legalEntityEdrpou: null,
      preferredChannels: [],
      phones: [],
      profileComplete: false
    });
    await expectAsync(pending).toBeResolvedTo(
      jasmine.objectContaining({ profileComplete: false })
    );
  });

  it('puts own profile via PUT /users/me/profile', async () => {
    const payload = {
      lastName: 'Шевченко',
      firstName: 'Тарас',
      patronymic: null,
      personType: 'INDIVIDUAL' as const,
      legalEntityEdrpou: null,
      preferredChannels: ['EMAIL' as const],
      phones: []
    };
    const pending = service.putMine(payload);
    const request = httpMock.expectOne(backendApi.myProfile);
    expect(request.request.method).toBe('PUT');
    expect(request.request.body).toEqual(payload);
    request.flush({ ...payload, phones: [], profileComplete: true });
    await expectAsync(pending).toBeResolvedTo(
      jasmine.objectContaining({ lastName: 'Шевченко', profileComplete: true })
    );
  });
});
