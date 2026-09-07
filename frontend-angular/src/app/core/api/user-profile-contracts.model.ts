/** Тип особи в профілі облікового запису. */
export type PersonTypeContract = 'INDIVIDUAL' | 'LEGAL_ENTITY_REPRESENTATIVE';

/** Бажаний канал зв'язку. */
export type ContactChannelContract = 'EMAIL' | 'PHONE' | 'MESSENGERS';

export interface UserContactPhoneContractDto {
  id: string;
  phone: string;
  primary: boolean;
  telegram: boolean;
  whatsapp: boolean;
  viber: boolean;
}

export interface UserProfileContractDto {
  lastName: string | null;
  firstName: string | null;
  patronymic: string | null;
  personType: PersonTypeContract | null;
  legalEntityEdrpou: string | null;
  preferredChannels: ContactChannelContract[];
  phones: UserContactPhoneContractDto[];
  profileComplete: boolean;
}

export interface UpdateUserContactPhoneRequest {
  id?: string;
  phone: string;
  primary?: boolean;
  telegram?: boolean;
  whatsapp?: boolean;
  viber?: boolean;
}

export interface UpdateUserProfileRequest {
  lastName: string;
  firstName: string;
  patronymic: string | null;
  personType: PersonTypeContract;
  legalEntityEdrpou: string | null;
  preferredChannels: ContactChannelContract[];
  phones: UpdateUserContactPhoneRequest[];
}

export function emptyUserProfile(): UserProfileContractDto {
  return {
    lastName: null,
    firstName: null,
    patronymic: null,
    personType: null,
    legalEntityEdrpou: null,
    preferredChannels: [],
    phones: [],
    profileComplete: false
  };
}
