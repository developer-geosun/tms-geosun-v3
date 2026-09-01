import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_error.dart';
import '../../../core/l10n/app_localizations.dart';
import '../data/directories_api.dart';
import '../domain/directory_models.dart';
import 'directory_format.dart';
import 'directory_page_body.dart';

/// Довідник курсів валют НБУ на обрану дату.
class ExchangeRatesDirectoryPage extends ConsumerStatefulWidget {
  const ExchangeRatesDirectoryPage({super.key});

  @override
  ConsumerState<ExchangeRatesDirectoryPage> createState() =>
      _ExchangeRatesDirectoryPageState();
}

class _ExchangeRatesDirectoryPageState
    extends ConsumerState<ExchangeRatesDirectoryPage> {
  DateTime _rateDate = DateTime.now();
  NbuRatesSnapshot? _snapshot;
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final snapshot = await ref
          .read(directoriesApiProvider)
          .getNbuRates(rateDate: formatDirectoryIsoDate(_rateDate));
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = snapshot;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = null;
        _isLoading = false;
        _errorMessage = isMissingNbuRates(error)
            ? null
            : directoryRatesErrorMessage(error, AppLocalizations.of(context));
      });
    }
  }

  Future<void> _syncRates() async {
    setState(() {
      _isSyncing = true;
      _errorMessage = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      final snapshot = await ref.read(directoriesApiProvider).syncNbuRates();
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = snapshot;
        if (snapshot.rateDate.isNotEmpty) {
          _rateDate = DateTime.tryParse(snapshot.rateDate) ?? _rateDate;
        }
        _isSyncing = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.directorySyncSuccess)));
    } on ApiException {
      if (!mounted) {
        return;
      }
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.directorySyncFailed)));
    }
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _rateDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() => _rateDate = selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final rates = _snapshot?.rates ?? const <NbuRate>[];
    final snapshotLabel = _snapshot == null
        ? null
        : l10n.directoryRatesSnapshot(
            _snapshot!.rateDate,
            formatDirectoryFetchedAt(_snapshot!.fetchedAt, localeName),
          );

    return DirectoryPageBody(
      header: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading || _isSyncing ? null : _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      '${l10n.directoryRateDate}: ${formatDirectoryIsoDate(_rateDate)}',
                    ),
                  ),
                ),
                DirectoryRefreshButton(
                  onPressed: _loadRates,
                  enabled: !_isLoading && !_isSyncing,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _isLoading || _isSyncing ? null : _loadRates,
                  child: Text(l10n.directoryLoadRates),
                ),
                OutlinedButton(
                  onPressed: _isLoading || _isSyncing ? null : _syncRates,
                  child: Text(
                    _isSyncing ? l10n.directorySyncing : l10n.directorySyncNbu,
                  ),
                ),
              ],
            ),
            if (snapshotLabel != null) ...[
              const SizedBox(height: 12),
              Text(
                snapshotLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      isEmpty: rates.isEmpty,
      emptyMessage: l10n.directoryRatesEmpty,
      itemCount: rates.length,
      itemBuilder: (context, index) {
        final rate = rates[index];
        return ListTile(
          title: Text(rate.currencyCode),
          subtitle: Text(
            '${l10n.directoryNbuUnits}: ${rate.nbuUnits} · '
            '${l10n.directoryRatePerUnit}: '
            '${formatDirectoryRate(rate.ratePerUnit, localeName)}',
          ),
        );
      },
    );
  }
}
