import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { NavigationEnd, Router, RouterLink, RouterOutlet } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { TranslateModule } from '@ngx-translate/core';
import { filter, map, startWith } from 'rxjs/operators';
import { LanguageService } from './core/services/language.service';
import { AuthService } from './core/services/auth.service';
import { ToolbarComponent } from './layout/toolbar/toolbar.component';
import { FooterComponent } from './layout/footer/footer.component';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  standalone: true,
  imports: [
    RouterOutlet,
    RouterLink,
    ToolbarComponent,
    FooterComponent,
    MatButtonModule,
    TranslateModule
  ]
})
export class AppComponent {
  // Ініціалізуємо сервіс під час старту застосунку
  private readonly languageService = inject(LanguageService);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);
  title = 'tms-geosun';

  private readonly currentUrl = toSignal(
    this.router.events.pipe(
      filter((e): e is NavigationEnd => e instanceof NavigationEnd),
      map(() => this.router.url),
      startWith(this.router.url)
    ),
    { initialValue: this.router.url }
  );

  /** Баннер неповноти профілю — не на /profile. */
  readonly showProfileBanner = computed(() => {
    if (!this.authService.isAuthenticated()) {
      return false;
    }
    const url = this.currentUrl();
    if (url === '/profile' || url.startsWith('/profile?')) {
      return false;
    }
    const profile = this.authService.user()?.profile;
    return profile != null && profile.profileComplete === false;
  });
}
