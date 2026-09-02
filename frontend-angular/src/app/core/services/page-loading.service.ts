import { Injectable, signal } from '@angular/core';

/** Мінімальний час показу полоски прогресу (мс). */
const MIN_VISIBLE_MS = 1000;

/** Глобальний індикатор завантаження списків — полоска під toolbar. */
@Injectable({ providedIn: 'root' })
export class PageLoadingService {
  private readonly active = signal(false);

  private shownAt: number | null = null;
  private hideTimer: ReturnType<typeof setTimeout> | null = null;

  /** Чи показувати полоску прогресу в toolbar. */
  readonly isActive = this.active.asReadonly();

  setActive(loading: boolean, options?: { immediate?: boolean }): void {
    if (loading) {
      this.clearHideTimer();
      if (!this.active()) {
        this.active.set(true);
      }
      this.shownAt = Date.now();
      return;
    }

    if (options?.immediate) {
      this.finishHide();
      return;
    }

    if (!this.active()) {
      return;
    }

    this.scheduleHide();
  }

  private scheduleHide(): void {
    this.clearHideTimer();

    if (this.shownAt === null) {
      this.finishHide();
      return;
    }

    const remaining = MIN_VISIBLE_MS - (Date.now() - this.shownAt);
    if (remaining <= 0) {
      this.finishHide();
      return;
    }

    this.hideTimer = setTimeout(() => this.finishHide(), remaining);
  }

  private finishHide(): void {
    this.clearHideTimer();
    this.shownAt = null;
    this.active.set(false);
  }

  private clearHideTimer(): void {
    if (this.hideTimer !== null) {
      clearTimeout(this.hideTimer);
      this.hideTimer = null;
    }
  }
}
