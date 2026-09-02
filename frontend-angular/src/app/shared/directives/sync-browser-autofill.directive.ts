import { AfterViewInit, DestroyRef, Directive, ElementRef, inject } from '@angular/core';
import { NgControl } from '@angular/forms';
import { AutofillMonitor } from '@angular/cdk/text-field';

/**
 * Синхронізує значення DOM-поля з FormControl після автозаповнення браузера
 * (Chrome Password Manager часто не генерує input-події для Angular Forms).
 */
@Directive({
  selector: 'input[appSyncBrowserAutofill]',
  standalone: true
})
export class SyncBrowserAutofillDirective implements AfterViewInit {
  private readonly elementRef = inject(ElementRef<HTMLInputElement>);
  private readonly ngControl = inject(NgControl, { self: true, optional: true });
  private readonly autofillMonitor = inject(AutofillMonitor);
  private readonly destroyRef = inject(DestroyRef);

  ngAfterViewInit(): void {
    const element = this.elementRef.nativeElement;

    const subscription = this.autofillMonitor.monitor(element).subscribe(() => {
      this.syncFromDom();
    });

    const onChange = (): void => {
      this.syncFromDom();
    };
    element.addEventListener('change', onChange);

    // Chrome може заповнити поле до підписки — перевіряємо одразу після ініціалізації.
    queueMicrotask(() => this.syncFromDom());

    this.destroyRef.onDestroy(() => {
      subscription.unsubscribe();
      element.removeEventListener('change', onChange);
      this.autofillMonitor.stopMonitoring(element);
    });
  }

  private syncFromDom(): void {
    const control = this.ngControl?.control;
    if (!control) {
      return;
    }

    const domValue = this.elementRef.nativeElement.value;
    if (domValue !== control.value) {
      control.setValue(domValue);
      control.markAsDirty();
      control.updateValueAndValidity();
    }
  }
}
