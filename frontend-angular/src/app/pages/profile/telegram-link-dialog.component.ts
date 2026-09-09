import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { TranslateModule } from '@ngx-translate/core';
import { BotLinkCodeContractResponse } from '../../core/api';

export interface TelegramLinkDialogData {
  link: BotLinkCodeContractResponse;
}

@Component({
  selector: 'app-telegram-link-dialog',
  standalone: true,
  imports: [CommonModule, MatDialogModule, MatButtonModule, MatIconModule, TranslateModule],
  templateUrl: './telegram-link-dialog.component.html',
  styleUrl: './telegram-link-dialog.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class TelegramLinkDialogComponent {
  private readonly dialogRef = inject(MatDialogRef<TelegramLinkDialogComponent>);
  readonly data = inject<TelegramLinkDialogData>(MAT_DIALOG_DATA);
  readonly copied = signal(false);

  openTelegram(): void {
    const url = this.data.link.deepLink;
    if (url) {
      window.open(url, '_blank', 'noopener');
    }
  }

  async copyCode(): Promise<void> {
    try {
      await navigator.clipboard.writeText(this.data.link.code);
      this.copied.set(true);
    } catch {
      this.copied.set(false);
    }
  }

  close(): void {
    this.dialogRef.close();
  }
}
