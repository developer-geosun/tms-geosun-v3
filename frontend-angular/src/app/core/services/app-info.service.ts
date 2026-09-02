import { HttpBackend, HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, map, of } from 'rxjs';
import { buildMeta } from '../../../environments/build-meta';
import { NGROK_SKIP_BROWSER_WARNING_HEADERS } from '../http/ngrok-headers';
import { ConfigService } from './config.service';

export interface ServerInfoDetails {
  apiVersion?: string;
  repositoryUrl?: string;
  version?: string;
  artifact?: string;
  buildTime?: string;
  commit?: string;
}

interface ActuatorInfoResponse {
  server?: ServerInfoDetails;
}

export interface ClientInfoDetails {
  version: string;
  appName: string;
  production: boolean;
  repositoryUrl: string;
  commit: string;
  commitFull: string;
  commitTime: string;
}

@Injectable({
  providedIn: 'root'
})
export class AppInfoService {
  private readonly http = new HttpClient(inject(HttpBackend));
  private readonly configService = inject(ConfigService);

  /** Локальні метадані Angular-клієнта. */
  getClientInfo(): ClientInfoDetails {
    const { environment } = this.configService;
    return {
      version: environment.version,
      appName: environment.appName,
      production: environment.production,
      repositoryUrl: environment.repositoryUrl,
      commit: buildMeta.commit,
      commitFull: buildMeta.commitFull,
      commitTime: buildMeta.commitTime
    };
  }

  /** Публічні метадані backend з {@code GET /actuator/info}. */
  fetchServerInfo(): Observable<ServerInfoDetails | null> {
    const options = { headers: NGROK_SKIP_BROWSER_WARNING_HEADERS };
    return this.http
      .get<ActuatorInfoResponse>(this.toBaseUrl('/actuator/info'), options)
      .pipe(
        map((response) => response?.server ?? null),
        catchError(() => of(null))
      );
  }

  private toBaseUrl(path: string): string {
    return `${this.configService.apiUrl}${path}`;
  }
}
