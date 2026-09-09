/** Канал чат-бота. */
export type ChatbotChannelContract = 'TELEGRAM' | 'WHATSAPP' | 'VIBER';

export type BotIdentityStatusContract = 'ACTIVE' | 'REVOKED';

export interface BotIdentitySelfContractDto {
  channel: ChatbotChannelContract;
  status: BotIdentityStatusContract;
  locale: string;
  linkedAt: string | null;
  phoneVerified: boolean;
}

export interface BotIdentitiesSelfContractResponse {
  items: BotIdentitySelfContractDto[];
}

export interface BotLinkCodeContractResponse {
  channel: ChatbotChannelContract;
  code: string;
  expiresAt: string;
  deepLink: string | null;
}

export interface ChannelStatusContractDto {
  channel: ChatbotChannelContract;
  enabled: boolean;
  configured: boolean;
  activeIdentities: number;
}

export interface AdminChatbotStatusContractDto {
  moduleEnabled: boolean;
  channels: ChannelStatusContractDto[];
}

export interface AdminBotIdentityContractDto {
  id: string;
  userId: string;
  channel: ChatbotChannelContract;
  externalUserId: string;
  locale: string;
  status: BotIdentityStatusContract;
  linkedAt: string | null;
  revokedAt: string | null;
}
