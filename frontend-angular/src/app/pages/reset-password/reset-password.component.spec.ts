import { TestBed } from '@angular/core/testing';
import { ActivatedRoute, convertToParamMap, provideRouter } from '@angular/router';
import { provideNoopAnimations } from '@angular/platform-browser/animations';
import { of } from 'rxjs';
import { TranslateModule } from '@ngx-translate/core';
import { ResetPasswordComponent } from './reset-password.component';
import { AuthService } from '../../core/services/auth.service';

describe('ResetPasswordComponent', () => {
  let authServiceSpy: jasmine.SpyObj<AuthService>;

  beforeEach(async () => {
    authServiceSpy = jasmine.createSpyObj<AuthService>('AuthService', [
      'getPasswordResetInfo',
      'resetPassword'
    ]);
    authServiceSpy.getPasswordResetInfo.and.returnValue(of({ email: 'user@example.com' }));
    authServiceSpy.resetPassword.and.returnValue(of({ success: true, message: 'ok' }));

    await TestBed.configureTestingModule({
      imports: [ResetPasswordComponent, TranslateModule.forRoot()],
      providers: [
        provideRouter([]),
        provideNoopAnimations(),
        { provide: AuthService, useValue: authServiceSpy },
        {
          provide: ActivatedRoute,
          useValue: {
            queryParamMap: of(convertToParamMap({ token: 'reset-token' }))
          }
        }
      ]
    }).compileComponents();
  });

  it('keeps the username field without readonly so Chrome can save the login', () => {
    const fixture = TestBed.createComponent(ResetPasswordComponent);
    fixture.detectChanges();

    const emailInput = fixture.nativeElement.querySelector('#reset-password-username') as HTMLInputElement;
    expect(emailInput).toBeTruthy();
    expect(emailInput.readOnly).toBeFalse();
    expect(emailInput.disabled).toBeFalse();
    expect(emailInput.getAttribute('autocomplete')).toBe('username');
    expect(emailInput.value).toBe('user@example.com');
  });

  it('submits a password that Chrome wrote into the DOM without input events', () => {
    const fixture = TestBed.createComponent(ResetPasswordComponent);
    fixture.detectChanges();

    const passwordInput = fixture.nativeElement.querySelector(
      'input[name="new-password"]'
    ) as HTMLInputElement;
    const confirmInput = fixture.nativeElement.querySelector(
      'input[name="confirm-new-password"]'
    ) as HTMLInputElement;
    passwordInput.value = 'pfF9xXV8gj8MA3N';
    confirmInput.value = 'pfF9xXV8gj8MA3N';

    fixture.componentInstance.submit();

    expect(authServiceSpy.resetPassword).toHaveBeenCalledWith({
      token: 'reset-token',
      newPassword: 'pfF9xXV8gj8MA3N'
    });
  });
});
