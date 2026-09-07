import { ChangeDetectionStrategy, Component, ElementRef, inject, signal, viewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { TranslateModule } from '@ngx-translate/core';
import { take } from 'rxjs';
import { AuthService } from '../../core/services';
import { PASSWORD_PATTERN } from '../../shared/constants';
import { SyncBrowserAutofillDirective } from '../../shared/directives/sync-browser-autofill.directive';

@Component({
  selector: 'app-reset-password',
  templateUrl: './reset-password.component.html',
  styleUrls: ['./reset-password.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterModule,
    MatCardModule,
    MatCheckboxModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    MatButtonModule,
    MatProgressSpinnerModule,
    TranslateModule,
    SyncBrowserAutofillDirective
  ]
})
export class ResetPasswordComponent {
  private readonly formBuilder = inject(FormBuilder);
  private readonly authService = inject(AuthService);
  private readonly activatedRoute = inject(ActivatedRoute);
  private readonly router = inject(Router);

  readonly isLoading = signal(false);
  readonly isResolvingAccount = signal(false);
  readonly hasSuccess = signal(false);
  readonly missingToken = signal(false);
  readonly accountEmail = signal<string | null>(null);
  readonly errorCode = signal<'invalid' | '429' | 'generic' | null>(null);
  readonly isPasswordVisible = signal(false);

  private readonly passwordInput = viewChild<ElementRef<HTMLInputElement>>('passwordInput');
  private readonly confirmPasswordInput = viewChild<ElementRef<HTMLInputElement>>('confirmPasswordInput');

  private resetToken = '';

  readonly form = this.formBuilder.nonNullable.group({
    email: [''],
    password: ['', [Validators.required, Validators.minLength(8), Validators.pattern(PASSWORD_PATTERN)]],
    confirmPassword: ['', [Validators.required, Validators.minLength(8)]]
  });

  constructor() {
    this.activatedRoute.queryParamMap.pipe(take(1)).subscribe((params) => {
      const token = params.get('token')?.trim() ?? '';
      if (!token) {
        this.missingToken.set(true);
        return;
      }
      this.resetToken = token;
      this.loadAccountEmail(token);
    });
  }

  submit(): void {
    this.syncPasswordsFromDom();
    if (
      this.missingToken() ||
      !this.resetToken ||
      !this.accountEmail() ||
      this.form.invalid ||
      this.isLoading() ||
      this.isResolvingAccount()
    ) {
      this.form.markAllAsTouched();
      return;
    }

    const values = this.form.getRawValue();
    if (values.password !== values.confirmPassword) {
      this.form.controls.confirmPassword.setErrors({
        ...(this.form.controls.confirmPassword.errors ?? {}),
        mismatch: true
      });
      this.form.controls.confirmPassword.markAsTouched();
      return;
    }

    this.errorCode.set(null);
    this.hasSuccess.set(false);
    this.isLoading.set(true);

    this.authService.resetPassword({ token: this.resetToken, newPassword: values.password }).subscribe({
      next: () => {
        this.isLoading.set(false);
        this.hasSuccess.set(true);
        void this.router.navigate(['/login']);
      },
      error: (error: { status?: number }) => {
        this.isLoading.set(false);
        if (error.status === 400) {
          this.errorCode.set('invalid');
          return;
        }
        if (error.status === 429) {
          this.errorCode.set('429');
          return;
        }
        this.errorCode.set('generic');
      }
    });
  }

  /** Показуємо пароль через property type, без [type]-binding — інакше Angular затирає підказку Chrome. */
  protected setPasswordVisible(visible: boolean): void {
    this.isPasswordVisible.set(visible);
    const type = visible ? 'text' : 'password';
    const password = this.passwordInput()?.nativeElement;
    const confirm = this.confirmPasswordInput()?.nativeElement;
    if (password) {
      password.type = type;
    }
    if (confirm) {
      confirm.type = type;
    }
  }

  /** Користувач не змінює email; поле лишається без readonly, щоб Chrome зберіг логін. */
  protected preventUsernameEdit(event: Event): void {
    if (event instanceof KeyboardEvent && this.isUsernameNavigationKey(event)) {
      return;
    }
    event.preventDefault();
  }

  private isUsernameNavigationKey(event: KeyboardEvent): boolean {
    if (event.key === 'Tab' || event.key === 'Escape') {
      return true;
    }
    if (event.key.startsWith('Arrow') || event.key === 'Home' || event.key === 'End') {
      return true;
    }
    const copyOrSelect = event.key === 'c' || event.key === 'C' || event.key === 'a' || event.key === 'A';
    return copyOrSelect && (event.ctrlKey || event.metaKey);
  }

  private syncPasswordsFromDom(): void {
    const password = this.passwordInput()?.nativeElement.value;
    const confirm = this.confirmPasswordInput()?.nativeElement.value;
    if (password != null && password !== this.form.controls.password.value) {
      this.form.controls.password.setValue(password);
      this.form.controls.password.markAsDirty();
    }
    if (confirm != null && confirm !== this.form.controls.confirmPassword.value) {
      this.form.controls.confirmPassword.setValue(confirm);
      this.form.controls.confirmPassword.markAsDirty();
    }
  }

  private loadAccountEmail(token: string): void {
    this.isResolvingAccount.set(true);
    this.errorCode.set(null);
    this.authService.getPasswordResetInfo({ token }).subscribe({
      next: (info) => {
        this.accountEmail.set(info.email);
        this.form.controls.email.setValue(info.email);
        this.isResolvingAccount.set(false);
      },
      error: (error: { status?: number }) => {
        this.isResolvingAccount.set(false);
        if (error.status === 400) {
          this.errorCode.set('invalid');
          return;
        }
        this.errorCode.set('generic');
      }
    });
  }
}
