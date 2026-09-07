import {
  ChangeDetectionStrategy,
  Component,
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
import {
  MAT_DIALOG_DATA,
  MatDialogModule,
  MatDialogRef
} from '@angular/material/dialog';
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
  UserAdminContractDto,
  UserProfileApiService,
  UserProfileContractDto,
  emptyUserProfile
} from '../../core/api';
import { extractApiError } from '../../core/utils/api-error';
import { showAppSnack } from '../../shared/utils/app-snackbar';
import { sanitizeDriverPersonNameInput } from '../admin-drivers/driver-person-name.util';

export interface UserProfileDialogData {
  user: UserAdminContractDto;
  readonly: boolean;
}

@Component({
  selector: 'app-user-profile-dialog',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    TranslateModule,
    MatButtonModule,
    MatCheckboxModule,
    MatDialogModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    MatRadioModule
  ],
  templateUrl: './user-profile-dialog.component.html',
  styleUrl: './user-profile-dialog.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserProfileDialogComponent {
  private readonly data = inject<UserProfileDialogData>(MAT_DIALOG_DATA);
  private readonly dialogRef = inject(MatDialogRef<UserProfileDialogComponent, boolean>);
  private readonly formBuilder = inject(FormBuilder);
  private readonly profileApi = inject(UserProfileApiService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly translate = inject(TranslateService);

  readonly readonly = this.data.readonly;
  readonly userEmail = this.data.user.email;
  readonly displayName = this.data.user.displayName;
  readonly isSaving = signal(false);

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

  readonly titleKey = computed(() =>
    this.readonly ? 'pages.adminUsers.viewProfile' : 'pages.adminUsers.editProfile'
  );

  constructor() {
    this.patchForm(this.data.user.profile ?? emptyUserProfile());
    if (this.readonly) {
      this.form.disable({ emitEvent: false });
    }
  }

  get phones(): FormArray {
    return this.form.controls.phones;
  }

  isLegalEntity(): boolean {
    return this.form.controls.personType.value === 'LEGAL_ENTITY_REPRESENTATIVE';
  }

  onPersonNameInput(controlName: 'lastName' | 'firstName' | 'patronymic', event: Event): void {
    if (this.readonly) {
      return;
    }
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
    if (this.readonly || this.phones.length >= 5) {
      return;
    }
    this.phones.push(this.createPhoneGroup(null, '', this.phones.length === 0, false, false, false));
  }

  removePhone(index: number): void {
    if (this.readonly) {
      return;
    }
    this.phones.removeAt(index);
    if (this.phones.length > 0 && !this.phones.controls.some((c) => c.get('primary')?.value)) {
      this.phones.at(0).get('primary')?.setValue(true);
    }
  }

  setPrimary(index: number): void {
    if (this.readonly) {
      return;
    }
    this.phones.controls.forEach((ctrl, i) => {
      ctrl.get('primary')?.setValue(i === index, { emitEvent: false });
    });
  }

  close(): void {
    this.dialogRef.close(false);
  }

  async save(): Promise<void> {
    if (this.readonly || this.form.invalid || this.isSaving()) {
      this.form.markAllAsTouched();
      return;
    }
    const payload = this.toRequest();
    if (!payload) {
      return;
    }
    this.isSaving.set(true);
    try {
      await this.profileApi.putAdmin(this.data.user.id, payload);
      showAppSnack(this.snackBar, this.translate, 'pages.adminUsers.profileSaved', 'success');
      this.dialogRef.close(true);
    } catch (error) {
      const api = extractApiError(error);
      const key =
        api.code === 'PROFILE_CHANNEL_PHONE_REQUIRED'
          ? 'pages.profile.errors.channelPhoneRequired'
          : api.code === 'PROFILE_CHANNEL_MESSENGER_REQUIRED'
            ? 'pages.profile.errors.channelMessengerRequired'
            : api.code === 'PROFILE_EDRPOU_FORBIDDEN'
              ? 'pages.profile.errors.edrpouForbidden'
              : api.code === 'PROFILE_PHONE_DUPLICATE'
                ? 'pages.profile.errors.phoneDuplicate'
                : 'pages.adminUsers.profileSaveFailed';
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
      channelEmail:
        profile.preferredChannels.includes('EMAIL') || profile.preferredChannels.length === 0,
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
      legalEntityEdrpou:
        personType === 'LEGAL_ENTITY_REPRESENTATIVE'
          ? raw.legalEntityEdrpou.replace(/\D/g, '') || null
          : null,
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
}
