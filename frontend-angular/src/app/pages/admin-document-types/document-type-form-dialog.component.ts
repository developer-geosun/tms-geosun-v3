import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  signal
} from '@angular/core';
import {
  AbstractControl,
  FormArray,
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators
} from '@angular/forms';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
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
import { MatSelectModule } from '@angular/material/select';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatStepperModule } from '@angular/material/stepper';
import {
  CountryReferenceApiService,
  CountryReferenceContractDto,
  CreateDocumentTypeContractRequest,
  DocumentTypeFieldDefinitionContractDto,
  DocumentTypeReferenceContractDto,
  DocumentTypeScanPageContractDto,
  DocumentTypesApiService
} from '../../core/api';
import {
  countryReferenceSelectLabel
} from '../../core/utils/country-reference-localized-name';
import { LanguageService } from '../../core/services/language.service';
import { showAppSnack } from '../../shared/utils/app-snackbar';

export interface DocumentTypeFormDialogData {
  documentType: DocumentTypeReferenceContractDto | null;
}

@Component({
  selector: 'app-document-type-form-dialog',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    TranslateModule,
    MatButtonModule,
    MatCheckboxModule,
    MatDialogModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    MatSelectModule,
    MatSnackBarModule,
    MatStepperModule
  ],
  templateUrl: './document-type-form-dialog.component.html',
  styleUrl: './document-type-form-dialog.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class DocumentTypeFormDialogComponent {
  private readonly data = inject<DocumentTypeFormDialogData>(MAT_DIALOG_DATA);
  private readonly dialogRef = inject(MatDialogRef<DocumentTypeFormDialogComponent, boolean>);
  private readonly formBuilder = inject(FormBuilder);
  private readonly documentTypesApi = inject(DocumentTypesApiService);
  private readonly countryReferenceApi = inject(CountryReferenceApiService);
  private readonly languageService = inject(LanguageService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly translate = inject(TranslateService);

  readonly documentType = signal<DocumentTypeReferenceContractDto | null>(this.data.documentType);
  readonly saving = signal(false);
  readonly countries = signal<CountryReferenceContractDto[]>([]);
  readonly stepIndex = signal(0);

  readonly isCreate = computed(() => this.documentType() == null);
  readonly isDeleted = computed(() => this.documentType()?.deleted === true);
  readonly onDescriptionStep = computed(() => this.stepIndex() === 0);
  readonly onFieldsStep = computed(() => this.stepIndex() === 1);

  readonly countrySelectOptions = computed(() => {
    const language = this.languageService.language();
    const locale = language === 'en' ? 'en' : language === 'ru' ? 'ru' : 'uk';
    return this.countries()
      .map((country) => ({
        code: country.codeAlpha2.toUpperCase(),
        label: countryReferenceSelectLabel(country, language)
      }))
      .sort((a, b) => a.label.localeCompare(b.label, locale));
  });

  readonly dialogTitle = computed(() => {
    if (this.isCreate()) {
      return this.translate.instant('pages.adminDocumentTypes.createTitle');
    }
    const row = this.documentType();
    if (!row) {
      return this.translate.instant('pages.adminDocumentTypes.editTitle');
    }
    const language = this.languageService.language();
    const name =
      language === 'en'
        ? row.nameEn
        : language === 'ru'
          ? row.nameRu
          : row.nameUk;
    const base = this.translate.instant('pages.adminDocumentTypes.editTitle');
    return name ? `${base} · ${name}` : base;
  });

  readonly descriptionForm = this.formBuilder.nonNullable.group({
    nameUk: ['', [Validators.required, Validators.maxLength(128)]],
    nameEn: ['', [Validators.required, Validators.maxLength(128)]],
    nameRu: ['', [Validators.required, Validators.maxLength(128)]],
    countryCode: ['UA', [Validators.required, Validators.minLength(2), Validators.maxLength(2)]],
    comment: ['', [Validators.maxLength(512)]],
    plannedScanPages: this.formBuilder.array<ReturnType<typeof this.createScanPageGroup>>([])
  });

  readonly fieldsStepForm = this.formBuilder.group({
    fieldDefinitions: this.formBuilder.array<ReturnType<typeof this.createFieldGroup>>([])
  });

  constructor() {
    void this.loadCountries();
    const row = this.documentType();
    if (row) {
      this.descriptionForm.patchValue({
        nameUk: row.nameUk,
        nameEn: row.nameEn,
        nameRu: row.nameRu,
        countryCode: row.countryCode.toUpperCase(),
        comment: row.comment ?? ''
      });
      for (const page of row.plannedScanPages ?? []) {
        this.plannedScanPages.push(this.createScanPageGroup(page));
      }
      for (const field of row.fieldDefinitions) {
        this.fieldDefinitions.push(this.createFieldGroup(field));
      }
      if (row.deleted) {
        this.descriptionForm.disable();
        this.fieldsStepForm.disable();
      }
    }
  }

  get plannedScanPages(): FormArray {
    return this.descriptionForm.controls.plannedScanPages;
  }

  get fieldDefinitions(): FormArray {
    return this.fieldsStepForm.controls.fieldDefinitions;
  }

  onStepChange(index: number): void {
    this.stepIndex.set(index);
  }

  goNext(): void {
    this.descriptionForm.markAllAsTouched();
    if (this.descriptionForm.invalid) {
      return;
    }
    this.onStepChange(1);
  }

  goPrev(): void {
    this.onStepChange(0);
  }

  addScanPageRow(): void {
    this.plannedScanPages.push(this.createScanPageGroup());
  }

  removeScanPageRow(index: number): void {
    this.plannedScanPages.removeAt(index);
  }

  scanPageGroupAt(index: number): FormGroup {
    return this.plannedScanPages.at(index) as FormGroup;
  }

  addFieldRow(): void {
    this.fieldDefinitions.push(this.createFieldGroup());
  }

  removeFieldRow(index: number): void {
    this.fieldDefinitions.removeAt(index);
  }

  fieldGroupAt(index: number): FormGroup {
    return this.fieldDefinitions.at(index) as FormGroup;
  }

  async submit(): Promise<void> {
    if (this.saving() || this.isDeleted()) {
      return;
    }
    this.descriptionForm.markAllAsTouched();
    this.fieldsStepForm.markAllAsTouched();
    if (this.descriptionForm.invalid || this.fieldsStepForm.invalid) {
      if (this.descriptionForm.invalid) {
        this.onStepChange(0);
      }
      return;
    }
    if (this.fieldDefinitions.length === 0) {
      showAppSnack(
        this.snackBar,
        this.translate,
        'pages.adminDocumentTypes.errors.DOCUMENT_TYPE_FIELDS_EMPTY',
        'error'
      );
      return;
    }
    const hasRequired = this.fieldDefinitions.controls.some(
      (control) => (control as FormGroup).controls['required'].value === true
    );
    if (!hasRequired) {
      showAppSnack(
        this.snackBar,
        this.translate,
        'pages.adminDocumentTypes.errors.DOCUMENT_TYPE_NO_REQUIRED_FIELD',
        'error'
      );
      return;
    }
    this.saving.set(true);
    try {
      const payload = this.buildPayload();
      const existing = this.documentType();
      if (existing) {
        await this.documentTypesApi.update(existing.id, payload);
        showAppSnack(
          this.snackBar,
          this.translate,
          'pages.adminDocumentTypes.updateSuccess'
        );
      } else {
        await this.documentTypesApi.create(payload);
        showAppSnack(
          this.snackBar,
          this.translate,
          'pages.adminDocumentTypes.createSuccess'
        );
      }
      this.dialogRef.close(true);
    } catch (err) {
      showAppSnack(
        this.snackBar,
        this.translate,
        this.mapError(err, 'pages.adminDocumentTypes.saveFailed'),
        'error'
      );
    } finally {
      this.saving.set(false);
    }
  }

  cancel(): void {
    this.dialogRef.close(false);
  }

  fieldError(control: AbstractControl | null, fieldKey: string): string {
    if (!control?.touched || !control.invalid) {
      return '';
    }
    if (control.hasError('required')) {
      return this.translate.instant('pages.adminDocumentTypes.errors.required', {
        field: this.translate.instant(`pages.adminDocumentTypes.${fieldKey}`)
      });
    }
    if (control.hasError('pattern')) {
      return this.translate.instant('pages.adminDocumentTypes.errors.fieldKeyPattern');
    }
    if (control.hasError('maxlength')) {
      return this.translate.instant('pages.adminDocumentTypes.errors.invalid');
    }
    return this.translate.instant('pages.adminDocumentTypes.errors.invalid');
  }

  private createScanPageGroup(value?: DocumentTypeScanPageContractDto) {
    return this.formBuilder.nonNullable.group({
      key: [value?.key ?? '', [Validators.required, Validators.maxLength(32)]],
      legendUa: [value?.legendUa ?? '', [Validators.required, Validators.maxLength(128)]],
      legendEn: [value?.legendEn ?? '', [Validators.required, Validators.maxLength(128)]],
      legendRu: [value?.legendRu ?? '', [Validators.required, Validators.maxLength(128)]]
    });
  }

  private createFieldGroup(value?: DocumentTypeFieldDefinitionContractDto) {
    return this.formBuilder.nonNullable.group({
      key: [
        value?.key ?? '',
        [Validators.required, Validators.maxLength(64), Validators.pattern(/^[a-zA-Z][a-zA-Z0-9_]*$/)]
      ],
      nameUk: [value?.nameUk ?? '', [Validators.required, Validators.maxLength(128)]],
      nameEn: [value?.nameEn ?? '', [Validators.required, Validators.maxLength(128)]],
      nameRu: [value?.nameRu ?? '', [Validators.required, Validators.maxLength(128)]],
      required: [value?.required ?? true]
    });
  }

  private buildPayload(): CreateDocumentTypeContractRequest {
    const description = this.descriptionForm.getRawValue();
    const fields = this.fieldsStepForm.getRawValue();
    return {
      nameUk: description.nameUk.trim(),
      nameEn: description.nameEn.trim(),
      nameRu: description.nameRu.trim(),
      countryCode: description.countryCode.trim().toUpperCase(),
      comment: (description.comment ?? '').trim(),
      plannedScanPages: description.plannedScanPages.map((page) => ({
        key: page.key.trim(),
        legendEn: page.legendEn.trim(),
        legendUa: page.legendUa.trim(),
        legendRu: page.legendRu.trim()
      })),
      fieldDefinitions: fields.fieldDefinitions.map((field) => ({
        key: field.key.trim(),
        nameUk: field.nameUk.trim(),
        nameEn: field.nameEn.trim(),
        nameRu: field.nameRu.trim(),
        required: field.required === true
      }))
    };
  }

  private async loadCountries(): Promise<void> {
    try {
      const list = await this.countryReferenceApi.list();
      this.countries.set(list);
    } catch {
      showAppSnack(
        this.snackBar,
        this.translate,
        'pages.adminDocumentTypes.countriesLoadFailed',
        'error'
      );
    }
  }

  private mapError(err: unknown, fallback: string): string {
    const code = (err as { error?: { code?: string } })?.error?.code;
    switch (code) {
      case 'DOCUMENT_TYPE_NAME_EXISTS':
        return 'pages.adminDocumentTypes.errors.DOCUMENT_TYPE_NAME_EXISTS';
      case 'COUNTRY_NOT_FOUND':
        return 'pages.adminDocumentTypes.errors.COUNTRY_NOT_FOUND';
      case 'DOCUMENT_TYPE_DELETED':
        return 'pages.adminDocumentTypes.errors.DOCUMENT_TYPE_DELETED';
      case 'DOCUMENT_TYPE_FIELDS_EMPTY':
        return 'pages.adminDocumentTypes.errors.DOCUMENT_TYPE_FIELDS_EMPTY';
      case 'DOCUMENT_TYPE_NO_REQUIRED_FIELD':
        return 'pages.adminDocumentTypes.errors.DOCUMENT_TYPE_NO_REQUIRED_FIELD';
      case 'DOCUMENT_TYPE_SCAN_PAGE_KEY_DUPLICATE':
        return 'pages.adminDocumentTypes.errors.DOCUMENT_TYPE_SCAN_PAGE_KEY_DUPLICATE';
      case 'VALIDATION_ERROR':
        return 'pages.adminDocumentTypes.errors.VALIDATION_ERROR';
      case 'NOT_FOUND':
        return 'pages.adminDocumentTypes.errors.NOT_FOUND';
      default:
        return fallback;
    }
  }
}
