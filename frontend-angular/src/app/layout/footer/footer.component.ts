import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatDialog } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { TranslateModule } from '@ngx-translate/core';
import { AuthService } from '../../core/services';
import { ConfigService } from '../../core/services/config.service';
import { AppInfoDialogComponent } from '../../shared/components/app-info-dialog/app-info-dialog.component';
import { SocialIconComponent } from '../../shared/components/social-icon/social-icon.component';
import { getHandsetFriendlyDialogConfig } from '../../shared/utils/handset-friendly-dialog-config';

/**
 * Компонент футера
 */
@Component({
  selector: 'app-footer',
  templateUrl: './footer.component.html',
  styleUrls: ['./footer.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  standalone: true,
  imports: [CommonModule, TranslateModule, MatTooltipModule, SocialIconComponent]
})
export class FooterComponent {
  currentYear = new Date().getFullYear();
  readonly configService = inject(ConfigService);
  readonly authService = inject(AuthService);
  private readonly dialog = inject(MatDialog);

  openAppInfoDialog(): void {
    this.dialog.open(
      AppInfoDialogComponent,
      getHandsetFriendlyDialogConfig({ autoFocus: false })
    );
  }
}

