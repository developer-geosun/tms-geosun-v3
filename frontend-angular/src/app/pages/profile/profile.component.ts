import {
  ChangeDetectionStrategy,
  Component,
  OnInit,
  computed,
  inject,
  signal
} from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  FormArray,
  FormBuilder,
  ReactiveFormsModule,
  Validators
} from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatRadioModule } from '@angular/material/radio';
import { MatSnackBar } from '@angular/material/snack-bar';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import {
  ContactChannelContract,
  PersonTypeContract,
  UpdateUserProfileRequest,
  UserProfileApiService,
  UserProfileContractDto
} from '../../core/api';
import { LayoutService } from '../../core/layout';
import { AuthService } from '../../core/services/auth.service';
import { extractApiError } from '../../core/utils/api-error';
import { showAppSnack } from '../../shared/utils/app-snackbar';
import { sanitizeDriverPersonNameInput } from '../admin-drivers/driver-person-name.util';
import { firstValueFrom } from 'rxjs';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    TranslateModule,
    MatButtonModule,
    MatCheckboxModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    MatRadioModule
  ],
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ProfileComponent implements OnInit {
  private readonly formBuilder = inject(FormBuilder);
  private readonly profileApi = inject(UserProfileApiService);
  private readonly authService = inject(AuthService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly translate = inject(TranslateService);
  private readonly layout = inject(LayoutService);

  readonly isHandset = this.layout.isHandset;
  readonly isLoading = signal(true);
  readonly isSaving = signal(false);
  readonly loadError = signal<string | null>(null);
  readonly userEmail = computed(() => this.authService.user()?.email ?? '');

  readonly form = this.formBuilder.nonNullable.group({
    lastName: ['', [Validators.required, Validators.maxLength(128)]],
    firstName: ['', [Validators.required, Validators.maxLength(128)]],
    patronymic: ['', [Validators.maxLength(128)]],
    personType: this.formBuilder.nonNullable.control<PersonTypeContract>('INDIVIDUAL'),
    legalEntityEdrpou: ['', [Validators.maxLength(10)]],
    channelEmail: [true],
    channelPhone: [false],
    channelMessengers: [false],
    phones: this.formBuilder.array([])
  });

  ngOnInit(): void {
    void this.reload();
  }

  get phones(): FormArray {
    return this.form.controls.phones;
  }

  isLegalEntity(): boolean {
    return this.form.controls.personType.value === 'LEGAL_ENTITY_REPRESENTATIVE';
  }

  onPersonNameInput(controlName: 'lastName' | 'firstName' | 'patronymic', event: Event): void {
    const input = event.target as HTMLInputElement;
    const sanitized = sanitizeDriverPersonNameInput(input.value);
    this.form.controls[controlName].setValue(sanitized, { emitEvent: false });
    input.value = sanitized;
  }

  onPersonTypeChange(): void {
    if (!this.isLegalEntity()) {
      this.form.controls.legalEntityEdrpou.setValue('');
    }
  }

  addPhone(): void {
    if (this.phones.length >= 5) {
      return;
    }
    const isFirst = this.phones.length === 0;
    this.phones.push(this.createPhoneGroup(null, '', isFirst, false, false, false));
    if (isFirst) {
      this.form.controls.channelPhone.setValue(true);
    }
  }

  removePhone(index: number): void {
    this.phones.removeAt(index);
    if (this.phones.length === 0) {
      return;
    }
    const hasPrimary = this.phones.controls.some((c) => c.get('primary')?.value === true);
    if (!hasPrimary) {
      this.phones.at(0).get('primary')?.setValue(true);
    }
  }

  setPrimary(index: number): void {
    this.phones.controls.forEach((ctrl, i) => {
      ctrl.get('primary')?.setValue(i === index, { emitEvent: false });
    });
  }

  async reload(): Promise<void> {
    this.isLoading.set(true);
    this.loadError.set(null);
    try {
      const profile = await this.profileApi.getMine();
      this.patchForm(profile);
    } catch {
      this.loadError.set('pages.profile.loadFailed');
    } finally {
      this.isSaving.set(false);
      this.isLoading.set(false);
    }
  }

  async save(): Promise<void> {
    if (this.form.invalid || this.isSaving()) {
      this.form.markAllAsTouched();
      return;
    }
    const payload = this.toRequest();
    if (!payload) {
      return;
    }
    this.isSaving.set(true);
    try {
      const saved = await this.profileApi.putMine(payload);
      this.patchForm(saved);
      await firstValueFrom(this.authService.getMe());
      showAppSnack(this.snackBar, this.translate, 'pages.profile.saveSuccess', 'success');
    } catch (error) {
      const api = extractApiError(error);
      const key = this.errorKey(api.code);
      showAppSnack(this.snackBar, this.translate, key, 'error');
    } finally {
      this.isSaving.set(false);
    }
  }

  private patchForm(profile: UserProfileContractDto): void {
    this.form.patchValue({
      lastName: profile.lastName ?? '',
      firstName: profile.firstName ?? '',
      patronymic: profile.patronymic ?? '',
      personType: profile.personType ?? 'INDIVIDUAL',
      legalEntityEdrpou: profile.legalEntityEdrpou ?? '',
      channelEmail: profile.preferredChannels.includes('EMAIL') || profile.preferredChannels.length === 0,
      channelPhone: profile.preferredChannels.includes('PHONE'),
      channelMessengers: profile.preferredChannels.includes('MESSENGERS')
    });
    this.phones.clear();
    for (const phone of profile.phones) {
      this.phones.push(
        this.createPhoneGroup(
          phone.id,
          phone.phone,
          phone.primary,
          phone.telegram,
          phone.whatsapp,
          phone.viber
        )
      );
    }
  }

  private createPhoneGroup(
    id: string | null,
    phone: string,
    primary: boolean,
    telegram: boolean,
    whatsapp: boolean,
    viber: boolean
  ) {
    return this.formBuilder.nonNullable.group({
      id: [id ?? ''],
      phone: [phone, [Validators.required, Validators.maxLength(32)]],
      primary: [primary],
      telegram: [telegram],
      whatsapp: [whatsapp],
      viber: [viber]
    });
  }

  private toRequest(): UpdateUserProfileRequest | null {
    const raw = this.form.getRawValue();
    const channels: ContactChannelContract[] = [];
    if (raw.channelEmail) {
      channels.push('EMAIL');
    }
    if (raw.channelPhone) {
      channels.push('PHONE');
    }
    if (raw.channelMessengers) {
      channels.push('MESSENGERS');
    }
    if (channels.length === 0) {
      showAppSnack(this.snackBar, this.translate, 'pages.profile.channelsRequired', 'error');
      return null;
    }

    const personType = raw.personType;
    const edrpou =
      personType === 'LEGAL_ENTITY_REPRESENTATIVE'
        ? raw.legalEntityEdrpou.replace(/\D/g, '') || null
        : null;

    const phoneRows = raw.phones as {
      id: string;
      phone: string;
      primary: boolean;
      telegram: boolean;
      whatsapp: boolean;
      viber: boolean;
    }[];

    return {
      lastName: sanitizeDriverPersonNameInput(raw.lastName),
      firstName: sanitizeDriverPersonNameInput(raw.firstName),
      patronymic: sanitizeDriverPersonNameInput(raw.patronymic) || null,
      personType,
      legalEntityEdrpou: edrpou,
      preferredChannels: channels,
      phones: phoneRows.map((p) => ({
        id: p.id || undefined,
        phone: p.phone.trim(),
        primary: p.primary,
        telegram: p.telegram,
        whatsapp: p.whatsapp,
        viber: p.viber
      }))
    };
  }

  private errorKey(code: string | null): string {
    switch (code) {
      case 'PROFILE_CHANNEL_PHONE_REQUIRED':
        return 'pages.profile.errors.channelPhoneRequired';
      case 'PROFILE_CHANNEL_MESSENGER_REQUIRED':
        return 'pages.profile.errors.channelMessengerRequired';
      case 'PROFILE_EDRPOU_FORBIDDEN':
        return 'pages.profile.errors.edrpouForbidden';
      case 'PROFILE_PHONE_DUPLICATE':
        return 'pages.profile.errors.phoneDuplicate';
      case 'PROFILE_PRIMARY_PHONE_INVALID':
        return 'pages.profile.errors.primaryPhoneInvalid';
      case 'VALIDATION_ERROR':
        return 'pages.profile.errors.validation';
      default:
        return 'pages.profile.saveFailed';
    }
  }
}
