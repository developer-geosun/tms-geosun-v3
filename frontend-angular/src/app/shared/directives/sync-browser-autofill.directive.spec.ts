import { Component } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { TestBed } from '@angular/core/testing';
import { SyncBrowserAutofillDirective } from './sync-browser-autofill.directive';

@Component({
  standalone: true,
  imports: [ReactiveFormsModule, SyncBrowserAutofillDirective],
  template: `
    <form [formGroup]="form">
      <input formControlName="password" autocomplete="new-password" appSyncBrowserAutofill />
      <button type="submit">Save</button>
    </form>
  `
})
class HostComponent {
  readonly form = new FormGroup({
    password: new FormControl('', { nonNullable: true })
  });
}

describe('SyncBrowserAutofillDirective', () => {
  it('copies a programmatically assigned DOM value into the FormControl', () => {
    const fixture = TestBed.configureTestingModule({
      imports: [HostComponent]
    }).createComponent(HostComponent);
    fixture.detectChanges();

    const input = fixture.nativeElement.querySelector('input') as HTMLInputElement;
    input.value = 'pfF9xXV8gj8MA3N';
    fixture.detectChanges();

    expect(fixture.componentInstance.form.controls.password.value).toBe('pfF9xXV8gj8MA3N');
  });

  it('syncs from DOM on native submit even if the value setter is bypassed', () => {
    const fixture = TestBed.configureTestingModule({
      imports: [HostComponent]
    }).createComponent(HostComponent);
    fixture.detectChanges();

    const input = fixture.nativeElement.querySelector('input') as HTMLInputElement;
    const proto = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value');
    proto?.set?.call(input, 'GeneratedPass1');

    expect(fixture.componentInstance.form.controls.password.value).toBe('');

    const form = fixture.nativeElement.querySelector('form') as HTMLFormElement;
    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));

    expect(fixture.componentInstance.form.controls.password.value).toBe('GeneratedPass1');
  });

  it('does not let a follow-up empty write wipe a just-generated password', () => {
    const fixture = TestBed.configureTestingModule({
      imports: [HostComponent]
    }).createComponent(HostComponent);
    fixture.detectChanges();

    const input = fixture.nativeElement.querySelector('input') as HTMLInputElement;
    input.value = 'GeneratedPass1';
    input.value = '';

    expect(input.value).toBe('GeneratedPass1');
    expect(fixture.componentInstance.form.controls.password.value).toBe('GeneratedPass1');
  });
});
