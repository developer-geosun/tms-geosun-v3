import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';
import { BackendApiService } from './backend-api.service';
import { PageResponse } from './page-response.model';
import {
  AdminBotIdentityContractDto,
  AdminChatbotStatusContractDto,
  BotIdentitiesSelfContractResponse,
  BotLinkCodeContractResponse,
  ChatbotChannelContract
} from './chatbot-contracts.model';

@Injectable({ providedIn: 'root' })
export class ChatbotApiService {
  private readonly http = inject(HttpClient);
  private readonly backendApi = inject(BackendApiService);

  async createLinkCode(channel: ChatbotChannelContract): Promise<BotLinkCodeContractResponse> {
    return firstValueFrom(
      this.http.post<BotLinkCodeContractResponse>(this.backendApi.myBotLinkCodes, { channel })
    );
  }

  async listMyIdentities(): Promise<BotIdentitiesSelfContractResponse> {
    return firstValueFrom(
      this.http.get<BotIdentitiesSelfContractResponse>(this.backendApi.myBotIdentities)
    );
  }

  async unlink(channel: ChatbotChannelContract): Promise<void> {
    await firstValueFrom(
      this.http.delete(
        `${this.backendApi.myBotIdentities}/${encodeURIComponent(channel)}`
      )
    );
  }

  async adminStatus(): Promise<AdminChatbotStatusContractDto> {
    return firstValueFrom(
      this.http.get<AdminChatbotStatusContractDto>(`${this.backendApi.adminChatbots}/status`)
    );
  }

  async adminIdentities(options: {
    page: number;
    size: number;
    channel?: ChatbotChannelContract;
  }): Promise<PageResponse<AdminBotIdentityContractDto>> {
    let params = new HttpParams()
      .set('page', String(options.page))
      .set('size', String(options.size));
    if (options.channel) {
      params = params.set('channel', options.channel);
    }
    return firstValueFrom(
      this.http.get<PageResponse<AdminBotIdentityContractDto>>(
        `${this.backendApi.adminChatbots}/identities`,
        { params }
      )
    );
  }
}
