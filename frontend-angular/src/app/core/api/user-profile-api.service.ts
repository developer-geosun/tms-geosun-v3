import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';
import { BackendApiService } from './backend-api.service';
import {
  UpdateUserProfileRequest,
  UserProfileContractDto
} from './user-profile-contracts.model';

@Injectable({ providedIn: 'root' })
export class UserProfileApiService {
  private readonly http = inject(HttpClient);
  private readonly backendApi = inject(BackendApiService);

  async getMine(): Promise<UserProfileContractDto> {
    return firstValueFrom(
      this.http.get<UserProfileContractDto>(this.backendApi.myProfile)
    );
  }

  async putMine(payload: UpdateUserProfileRequest): Promise<UserProfileContractDto> {
    return firstValueFrom(
      this.http.put<UserProfileContractDto>(this.backendApi.myProfile, payload)
    );
  }

  async putAdmin(userId: string, payload: UpdateUserProfileRequest): Promise<UserProfileContractDto> {
    return firstValueFrom(
      this.http.put<UserProfileContractDto>(
        `${this.backendApi.adminUsers}/${encodeURIComponent(userId)}/profile`,
        payload
      )
    );
  }
}
