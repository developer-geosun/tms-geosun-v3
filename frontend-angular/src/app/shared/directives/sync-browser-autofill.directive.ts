import { AfterViewInit, DestroyRef, Directive, ElementRef, inject, NgZone } from '@angular/core';
import { NgControl } from '@angular/forms';
import { AutofillMonitor } from '@angular/cdk/text-field';

/**
 * Синхронізує значення DOM-поля з FormControl після автозаповнення / генерації пароля.
 * Chrome Password Manager часто пише input.value без input-події, і Angular вважає поле порожнім.
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
  private readonly ngZone = inject(NgZone);

  private pollTimer: ReturnType<typeof setInterval> | null = null;
  private pollUntil = 0;
  private lastNonEmptyDomWriteAt = 0;

  ngAfterViewInit(): void {
    const element = this.elementRef.nativeElement;
    const form = element.closest('form');

    const subscription = this.autofillMonitor.monitor(element).subscribe(() => {
      this.syncFromDom();
    });

    const onDomEvent = (): void => {
      this.syncFromDom();
      this.startPolling(2500);
    };
    const domEvents: (keyof HTMLElementEventMap)[] = ['input', 'change', 'blur', 'keyup', 'focus'];
    for (const eventName of domEvents) {
      element.addEventListener(eventName, onDomEvent);
    }

    const onAnimationStart = (event: AnimationEvent): void => {
      if (event.animationName.toLowerCase().includes('autofill')) {
        this.syncFromDom();
      }
    };
    element.addEventListener('animationstart', onAnimationStart);

    const onFormSubmit = (): void => {
      this.syncFromDom();
    };
    form?.addEventListener('submit', onFormSubmit, true);

    const onFormFocusIn = (): void => {
      this.startPolling(3000);
    };
    form?.addEventListener('focusin', onFormFocusIn);

    const onWindowFocus = (): void => {
      this.syncFromDom();
      this.startPolling(2500);
    };
    window.addEventListener('focus', onWindowFocus);

    const uninstallValueInterceptor = this.installValueInterceptor(element);

    queueMicrotask(() => this.syncFromDom());
    this.startPolling(1500);

    this.destroyRef.onDestroy(() => {
      this.stopPolling();
      uninstallValueInterceptor();
      subscription.unsubscribe();
      for (const eventName of domEvents) {
        element.removeEventListener(eventName, onDomEvent);
      }
      element.removeEventListener('animationstart', onAnimationStart);
      form?.removeEventListener('submit', onFormSubmit, true);
      form?.removeEventListener('focusin', onFormFocusIn);
      window.removeEventListener('focus', onWindowFocus);
      this.autofillMonitor.stopMonitoring(element);
    });
  }

  private installValueInterceptor(element: HTMLInputElement): () => void {
    const proto = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value');
    if (!proto?.get || !proto?.set) {
      return () => undefined;
    }

    try {
      Object.defineProperty(element, 'value', {
        configurable: true,
        enumerable: proto.enumerable ?? true,
        get: () => proto.get!.call(element),
        set: (next: string) => {
          const incoming = String(next ?? '');
          const current = String(proto.get!.call(element) ?? '');
          const recentlyFilled =
            incoming === '' && current !== '' && Date.now() - this.lastNonEmptyDomWriteAt < 1000;
          if (recentlyFilled) {
            this.syncFromDom();
            return;
          }
          proto.set!.call(element, next);
          if (incoming !== '') {
            this.lastNonEmptyDomWriteAt = Date.now();
          }
          this.syncFromDom();
        }
      });
    } catch {
      return () => undefined;
    }

    return () => {
      try {
        delete (element as unknown as { value?: string }).value;
      } catch {
        // Браузер може заборонити знімати перехоплювач — тоді лишається polling.
      }
    };
  }

  private startPolling(durationMs: number): void {
    this.pollUntil = Math.max(this.pollUntil, Date.now() + durationMs);
    if (this.pollTimer != null) {
      return;
    }

    this.ngZone.runOutsideAngular(() => {
      this.pollTimer = setInterval(() => {
        const focused = document.activeElement === this.elementRef.nativeElement;
        if (!focused && Date.now() >= this.pollUntil) {
          this.stopPolling();
          return;
        }
        this.syncFromDom();
      }, 50);
    });
  }

  private stopPolling(): void {
    if (this.pollTimer == null) {
      return;
    }
    clearInterval(this.pollTimer);
    this.pollTimer = null;
  }

  private syncFromDom(): void {
    const control = this.ngControl?.control;
    if (!control) {
      return;
    }

    const domValue = this.elementRef.nativeElement.value;
    if (domValue === (control.value ?? '')) {
      return;
    }

    const apply = (): void => {
      control.setValue(domValue);
      control.markAsDirty();
      control.updateValueAndValidity();
    };

    if (NgZone.isInAngularZone()) {
      apply();
      return;
    }
    this.ngZone.run(apply);
  }
}
