import { DestroyRef, effect, inject, Signal } from '@angular/core';
import { PageLoadingService } from '../../core/services/page-loading.service';

/** Синхронізує сигнал завантаження сторінки з полоскою прогресу в toolbar. */
export function syncPageLoadingToToolbar(loading: Signal<boolean>): void {
  const pageLoading = inject(PageLoadingService);
  const destroyRef = inject(DestroyRef);

  effect(() => {
    pageLoading.setActive(loading());
  });

  destroyRef.onDestroy(() => {
    pageLoading.setActive(false, { immediate: true });
  });
}
