import {
  ChangeDetectionStrategy,
  Component,
  DestroyRef,
  OnInit,
  computed,
  inject,
  signal
} from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { CommonModule } from '@angular/common';
import {
  FormArray,
  FormBuilder,
  ReactiveFormsModule,
  Validators
} from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatRadioModule } from '@angular/material/radio';
import { MatSnackBar } from '@angular/material/snack-bar';
import { MatDialog } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { Router } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import {
  BotIdentitySelfContractDto,
  ChatbotApiService,
  ContactChannelContract,
  PersonTypeContract,
  UpdateUserProfileRequest,
  UserProfileApiService,
  UserProfileContractDto
} from '../../core/api';
import { LayoutService } from '../../core/layout';
import { AuthService } from '../../core/services/auth.service';
import { extractApiError } from '../../core/utils/api-error';
import { ConfirmDialogComponent } from '../../shared/components/confirm-dialog/confirm-dialog.component';
import { getHandsetFriendlyDialogConfig } from '../../shared/utils/handset-friendly-dialog-config';
import { showAppSnack } from '../../shared/utils/app-snackbar';
import { sanitizeDriverPersonNameInput } from '../admin-drivers/driver-person-name.util';
import { TelegramLinkDialogComponent } from './telegram-link-dialog.component';
import { firstValueFrom } from 'rxjs';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    TranslateModule,
    MatButtonModule,
    MatCardModule,
    MatCheckboxModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    MatRadioModule,
    MatTooltipModule
  ],
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ProfileComponent implements OnInit {
  private readonly formBuilder = inject(FormBuilder);
  private readonly profileApi = inject(UserProfileApiService);
  private readonly chatbotApi = inject(ChatbotApiService);
  private readonly authService = inject(AuthService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly dialog = inject(MatDialog);
  private readonly translate = inject(TranslateService);
  private readonly layout = inject(LayoutService);
  private readonly destroyRef = inject(DestroyRef);
  private readonly router = inject(Router);

  readonly isHandset = this.layout.isHandset;
  readonly isLoading = signal(true);
  readonly isSaving = signal(false);
  readonly isDirty = signal(false);
  readonly loadError = signal<string | null>(null);
  readonly userEmail = computed(() => this.authService.user()?.email ?? '');
  readonly isAdmin = computed(() => this.authService.hasAnyRole(['admin']));
  /** Прив'язка Telegram (окремо від форми профілю). */
  readonly telegramIdentity = signal<BotIdentitySelfContractDto | null>(null);
  readonly telegramBusy = signal(false);
  /** verified за id телефону з останнього GET профілю. */
  readonly phoneVerifiedById = signal<Record<string, boolean>>({});

  readonly form = this.formBuilder.nonNullable.group({
    lastName: ['', [Validators.required, Validators.maxLength(128)]],
    firstName: ['', [Validators.required, Validators.maxLength(128)]],
    patronymic: ['', [Validators.maxLength(128)]],
    personType: this.formBuilder.nonNullable.control<PersonTypeContract>('INDIVIDUAL'),
    legalEntityEdrpou: [{ value: '', disabled: true }, [Validators.maxLength(10)]],
    channelEmail: [true],
    channelPhone: [false],
    channelMessengers: [false],
    phones: this.formBuilder.array([])
  });

  constructor() {
    this.syncPhoneDependentChannels();
    this.form.valueChanges.pipe(takeUntilDestroyed(this.destroyRef)).subscribe(() => {
      this.isDirty.set(this.form.dirty);
    });
  }

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
    this.form.controls[controlName].markAsDirty();
    this.isDirty.set(true);
  }

  onPersonTypeChange(): void {
    this.syncLegalEntityEdrpouState({ clearWhenIndividual: true });
    this.form.markAsDirty();
    this.isDirty.set(true);
  }

  addPhone(): void {
    if (this.phones.length >= 5) {
      return;
    }
    const isFirst = this.phones.length === 0;
    this.phones.push(this.createPhoneGroup(null, '', isFirst, false, false, false));
    this.syncPhoneDependentChannels();
    if (isFirst) {
      this.form.controls.channelPhone.setValue(true);
    }
    this.form.markAsDirty();
    this.isDirty.set(true);
  }

  async removePhone(index: number): Promise<void> {
    const ok = await firstValueFrom(
      this.dialog
        .open(ConfirmDialogComponent, {
          data: { messageKey: 'pages.profile.removePhoneConfirm' }
        })
        .afterClosed()
    );
    if (!ok) {
      return;
    }

    this.phones.removeAt(index);
    if (this.phones.length > 0) {
      const hasPrimary = this.phones.controls.some((c) => c.get('primary')?.value === true);
      if (!hasPrimary) {
        this.phones.at(0).get('primary')?.setValue(true, { emitEvent: false });
      }
    }
    this.syncPhoneDependentChannels();
    this.form.markAsDirty();
    this.isDirty.set(true);
  }

  setPrimary(index: number): void {
    this.phones.controls.forEach((ctrl, i) => {
      ctrl.get('primary')?.setValue(i === index, { emitEvent: false });
    });
    this.form.markAsDirty();
    this.isDirty.set(true);
  }

  /** Закрити картку й повернутися на головну; при брудній формі — підтвердження. */
  async close(): Promise<void> {
    if (this.isDirty()) {
      const ok = await firstValueFrom(
        this.dialog
          .open(ConfirmDialogComponent, {
            data: { messageKey: 'pages.profile.closeUnsavedConfirm' }
          })
          .afterClosed()
      );
      if (!ok) {
        return;
      }
    }
    await this.router.navigateByUrl('/main');
  }

  async reload(): Promise<void> {
    this.isLoading.set(true);
    this.loadError.set(null);
    try {
      const [profile] = await Promise.all([this.profileApi.getMine(), this.reloadTelegramIdentity()]);
      this.patchForm(profile);
    } catch {
      this.loadError.set('pages.profile.loadFailed');
    } finally {
      this.isSaving.set(false);
      this.isLoading.set(false);
    }
  }

  isPhoneVerified(index: number): boolean {
    const id = this.phones.at(index)?.get('id')?.value as string | undefined;
    if (!id) {
      return false;
    }
    return this.phoneVerifiedById()[id] === true;
  }

  /**
   * Кнопки прив'язки Telegram — на картці з позначеним Telegram
   * (або на основному / першому телефоні).
   */
  isTelegramActionPhone(index: number): boolean {
    return index === this.telegramActionPhoneIndex();
  }

  private telegramActionPhoneIndex(): number {
    if (this.phones.length === 0) {
      return -1;
    }
    const withTelegram = this.phones.controls.findIndex(
      (c) => c.get('telegram')?.value === true
    );
    if (withTelegram >= 0) {
      return withTelegram;
    }
    const primary = this.phones.controls.findIndex((c) => c.get('primary')?.value === true);
    return primary >= 0 ? primary : 0;
  }

  async startTelegramLink(): Promise<void> {
    if (this.telegramBusy()) {
      return;
    }
    this.telegramBusy.set(true);
    try {
      const link = await this.chatbotApi.createLinkCode('TELEGRAM');
      const ref = this.dialog.open(
        TelegramLinkDialogComponent,
        getHandsetFriendlyDialogConfig({
          data: { link },
          width: 'min(420px, calc(100vw - 24px))'
        })
      );
      await firstValueFrom(ref.afterClosed());
      await this.reloadTelegramIdentity();
      // Не затираємо незбережені правки форми.
      if (!this.isDirty()) {
        const profile = await this.profileApi.getMine();
        this.patchForm(profile);
      }
    } catch (error) {
      const api = extractApiError(error);
      const key =
        api.code === 'BOT_ALREADY_LINKED'
          ? 'pages.profile.telegram.alreadyLinked'
          : api.code === 'BOT_CHANNEL_DISABLED'
            ? 'pages.profile.telegram.channelDisabled'
            : 'pages.profile.telegram.linkFailed';
      showAppSnack(this.snackBar, this.translate, key, 'error');
    } finally {
      this.telegramBusy.set(false);
    }
  }

  async unlinkTelegram(): Promise<void> {
    const ok = await firstValueFrom(
      this.dialog
        .open(ConfirmDialogComponent, {
          data: { messageKey: 'pages.profile.telegram.unlinkConfirm' }
        })
        .afterClosed()
    );
    if (!ok) {
      return;
    }
    this.telegramBusy.set(true);
    try {
      await this.chatbotApi.unlink('TELEGRAM');
      this.telegramIdentity.set(null);
      showAppSnack(this.snackBar, this.translate, 'pages.profile.telegram.unlinked', 'success');
    } catch {
      showAppSnack(this.snackBar, this.translate, 'pages.profile.telegram.unlinkFailed', 'error');
    } finally {
      this.telegramBusy.set(false);
    }
  }

  private async reloadTelegramIdentity(): Promise<void> {
    try {
      const res = await this.chatbotApi.listMyIdentities();
      const tg = res.items.find((i) => i.channel === 'TELEGRAM' && i.status === 'ACTIVE') ?? null;
      this.telegramIdentity.set(tg);
    } catch {
      this.telegramIdentity.set(null);
    }
  }

  async save(): Promise<void> {
    if (this.isSaving() || !this.isDirty()) {
      return;
    }

    const clientError = this.validateClient();
    if (clientError) {
      this.form.markAllAsTouched();
      showAppSnack(this.snackBar, this.translate, clientError, 'error');
      return;
    }

    const payload = this.toRequest();
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
    const verifiedMap: Record<string, boolean> = {};
    for (const phone of profile.phones) {
      verifiedMap[phone.id] = phone.verified === true;
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
    this.phoneVerifiedById.set(verifiedMap);
    this.syncLegalEntityEdrpouState({ clearWhenIndividual: false });
    this.syncPhoneDependentChannels();
    this.form.markAsPristine();
    this.form.markAsUntouched();
    this.isDirty.set(false);
  }

  /** ЄДРПОУ завжди в формі; редагування лише для представника юрособи. */
  private syncLegalEntityEdrpouState(options: { clearWhenIndividual: boolean }): void {
    const ctrl = this.form.controls.legalEntityEdrpou;
    if (this.isLegalEntity()) {
      ctrl.enable({ emitEvent: false });
      return;
    }
    if (options.clearWhenIndividual) {
      ctrl.setValue('', { emitEvent: false });
    }
    ctrl.disable({ emitEvent: false });
  }

  /**
   * Без телефонів канали PHONE / MESSENGERS недоступні
   * (і знімаються, якщо були позначені).
   */
  private syncPhoneDependentChannels(): void {
    const phoneChannel = this.form.controls.channelPhone;
    const messengersChannel = this.form.controls.channelMessengers;
    if (this.phones.length > 0) {
      phoneChannel.enable({ emitEvent: false });
      messengersChannel.enable({ emitEvent: false });
      return;
    }
    phoneChannel.setValue(false, { emitEvent: false });
    messengersChannel.setValue(false, { emitEvent: false });
    phoneChannel.disable({ emitEvent: false });
    messengersChannel.disable({ emitEvent: false });
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

  /** Клієнтська перевірка перед відправкою; повертає ключ i18n або null. */
  private validateClient(): string | null {
    if (this.form.invalid) {
      return 'pages.profile.errors.validation';
    }

    const raw = this.form.getRawValue();
    const hasChannel = raw.channelEmail || raw.channelPhone || raw.channelMessengers;
    if (!hasChannel) {
      return 'pages.profile.channelsRequired';
    }

    const phoneRows = raw.phones as {
      phone: string;
      telegram: boolean;
      whatsapp: boolean;
      viber: boolean;
    }[];

    if (raw.channelPhone) {
      const hasPhone = phoneRows.some((p) => p.phone.trim().length > 0);
      if (!hasPhone) {
        return 'pages.profile.errors.channelPhoneRequired';
      }
    }

    if (raw.channelMessengers) {
      const hasMessenger = phoneRows.some((p) => p.telegram || p.whatsapp || p.viber);
      if (!hasMessenger) {
        return 'pages.profile.errors.channelMessengerRequired';
      }
    }

    return null;
  }

  private toRequest(): UpdateUserProfileRequest {
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
