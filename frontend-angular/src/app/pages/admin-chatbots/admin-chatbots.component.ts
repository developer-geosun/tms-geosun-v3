import {
  AfterViewInit,
  ChangeDetectionStrategy,
  Component,
  ViewChild,
  inject,
  signal
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { MatPaginator, MatPaginatorModule } from '@angular/material/paginator';
import { MatSnackBar } from '@angular/material/snack-bar';
import { MatTableDataSource, MatTableModule } from '@angular/material/table';
import { MatTooltipModule } from '@angular/material/tooltip';
import {
  AdminBotIdentityContractDto,
  AdminChatbotStatusContractDto,
  ChatbotApiService
} from '../../core/api';
import { LayoutService } from '../../core/layout';
import { extractApiError } from '../../core/utils/api-error';
import { showAppSnack } from '../../shared/utils/app-snackbar';
import { syncPageLoadingToToolbar } from '../../shared/utils/sync-page-loading-to-toolbar';

@Component({
  selector: 'app-admin-chatbots',
  standalone: true,
  imports: [
    CommonModule,
    TranslateModule,
    MatButtonModule,
    MatCardModule,
    MatChipsModule,
    MatIconModule,
    MatPaginatorModule,
    MatTableModule,
    MatTooltipModule
  ],
  templateUrl: './admin-chatbots.component.html',
  styleUrl: './admin-chatbots.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminChatbotsComponent implements AfterViewInit {
  private readonly chatbotApi = inject(ChatbotApiService);
  private readonly layout = inject(LayoutService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly translate = inject(TranslateService);

  readonly isHandset = this.layout.isHandset;
  readonly isLoading = signal(false);
  readonly loadError = signal('');
  readonly status = signal<AdminChatbotStatusContractDto | null>(null);
  readonly dataSource = new MatTableDataSource<AdminBotIdentityContractDto>([]);
  readonly displayedColumns = [
    'channel',
    'userId',
    'externalUserId',
    'status',
    'linkedAt'
  ];
  readonly totalElements = signal(0);
  readonly pageIndex = signal(0);
  readonly pageSize = signal(20);

  @ViewChild(MatPaginator) private paginator?: MatPaginator;

  constructor() {
    syncPageLoadingToToolbar(this.isLoading);
  }

  ngAfterViewInit(): void {
    void this.reload();
  }

  async reload(): Promise<void> {
    this.isLoading.set(true);
    this.loadError.set('');
    try {
      const [status, page] = await Promise.all([
        this.chatbotApi.adminStatus(),
        this.chatbotApi.adminIdentities({
          page: this.pageIndex(),
          size: this.pageSize()
        })
      ]);
      this.status.set(status);
      this.dataSource.data = page.content;
      this.totalElements.set(page.totalElements);
    } catch (error) {
      this.loadError.set('pages.adminChatbots.loadFailed');
      showAppSnack(
        this.snackBar,
        this.translate,
        extractApiError(error).code ? 'pages.adminChatbots.loadFailed' : 'pages.adminChatbots.loadFailed',
        'error'
      );
    } finally {
      this.isLoading.set(false);
    }
  }

  onPage(event: { pageIndex: number; pageSize: number }): void {
    this.pageIndex.set(event.pageIndex);
    this.pageSize.set(event.pageSize);
    void this.reload();
  }
}
