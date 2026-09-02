import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { TranslateModule } from '@ngx-translate/core';
import {
  AppInfoService,
  ClientInfoDetails,
  ServerInfoDetails
} from '../../../core/services/app-info.service';

interface InfoRow {
  labelKey: string;
  value: string;
  href?: string;
  translateValue?: boolean;
}

function commitHref(repositoryUrl: string, commit: string): string | undefined {
  const hash = commit.trim();
  if (!hash || hash === 'dev') {
    return undefined;
  }
  const base = repositoryUrl.replace(/\.git$/, '');
  return `${base}/commit/${hash}`;
}

@Component({
  selector: 'app-app-info-dialog',
  standalone: true,
  imports: [MatDialogModule, MatButtonModule, MatProgressSpinnerModule, TranslateModule],
  templateUrl: './app-info-dialog.component.html',
  styleUrls: ['./app-info-dialog.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AppInfoDialogComponent {
  private readonly appInfoService = inject(AppInfoService);
  private readonly dialogRef = inject(MatDialogRef<AppInfoDialogComponent>);

  readonly loading = signal(true);
  readonly serverError = signal(false);
  readonly clientRows = signal<InfoRow[]>(this.buildClientRows(this.appInfoService.getClientInfo()));
  readonly serverRows = signal<InfoRow[]>([]);

  constructor() {
    this.appInfoService.fetchServerInfo().subscribe((serverInfo) => {
      this.loading.set(false);
      if (!serverInfo) {
        this.serverError.set(true);
        return;
      }
      this.serverRows.set(this.buildServerRows(serverInfo));
    });
  }

  close(): void {
    this.dialogRef.close();
  }

  private buildClientRows(clientInfo: ClientInfoDetails): InfoRow[] {
    const rows: InfoRow[] = [
      { labelKey: 'common.appInfoDialog.fields.appName', value: clientInfo.appName },
      { labelKey: 'common.appInfoDialog.fields.version', value: clientInfo.version },
      {
        labelKey: 'common.appInfoDialog.fields.production',
        value: clientInfo.production
          ? 'common.appInfoDialog.values.yes'
          : 'common.appInfoDialog.values.no',
        translateValue: true
      }
    ];

    const clientCommitHref = commitHref(clientInfo.repositoryUrl, clientInfo.commit);
    rows.push({
      labelKey: 'common.appInfoDialog.fields.commit',
      value: clientInfo.commit,
      href: clientCommitHref
    });

    rows.push({
      labelKey: 'common.appInfoDialog.fields.repositoryUrl',
      value: clientInfo.repositoryUrl,
      href: clientInfo.repositoryUrl
    });

    return rows;
  }

  private buildServerRows(serverInfo: ServerInfoDetails): InfoRow[] {
    const rows: InfoRow[] = [];

    if (serverInfo.version) {
      rows.push({
        labelKey: 'common.appInfoDialog.fields.version',
        value: serverInfo.version
      });
    }
    if (serverInfo.apiVersion) {
      rows.push({
        labelKey: 'common.appInfoDialog.fields.apiVersion',
        value: serverInfo.apiVersion
      });
    }
    if (serverInfo.artifact) {
      rows.push({
        labelKey: 'common.appInfoDialog.fields.artifact',
        value: serverInfo.artifact
      });
    }
    if (serverInfo.buildTime) {
      rows.push({
        labelKey: 'common.appInfoDialog.fields.buildTime',
        value: serverInfo.buildTime
      });
    }
    if (serverInfo.commit) {
      rows.push({
        labelKey: 'common.appInfoDialog.fields.commit',
        value: serverInfo.commit,
        href: commitHref(serverInfo.repositoryUrl ?? '', serverInfo.commit)
      });
    }
    if (serverInfo.repositoryUrl) {
      rows.push({
        labelKey: 'common.appInfoDialog.fields.repositoryUrl',
        value: serverInfo.repositoryUrl,
        href: serverInfo.repositoryUrl
      });
    }

    return rows;
  }
}
