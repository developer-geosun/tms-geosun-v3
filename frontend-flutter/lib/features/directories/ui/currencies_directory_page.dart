import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_error.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../data/directories_api.dart';
import '../domain/directory_models.dart';
import 'directory_format.dart';
import 'directory_page_body.dart';

/// Довідник валют з останнім курсом НБУ.
class CurrenciesDirectoryPage extends ConsumerStatefulWidget {
  const CurrenciesDirectoryPage({super.key});

  @override
  ConsumerState<CurrenciesDirectoryPage> createState() =>
      _CurrenciesDirectoryPageState();
}

class _CurrenciesDirectoryPageState
    extends ConsumerState<CurrenciesDirectoryPage> {
  List<CurrencyReference> _currencies = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final currencies = await ref
          .read(directoriesApiProvider)
          .listCurrencies();
      if (!mounted) {
        return;
      }
      setState(() {
        _currencies = currencies;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _currencies = const [];
        _isLoading = false;
      });
      showAppSnack(
        context,
        message: directoryErrorMessage(error, AppLocalizations.of(context)),
        kind: AppSnackKind.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final languageCode = Localizations.localeOf(context).languageCode;

    return DirectoryPageBody(
      header: Align(
        alignment: Alignment.centerRight,
        child: DirectoryRefreshButton(onPressed: _reload, enabled: !_isLoading),
      ),
      isLoading: _isLoading,
      isEmpty: _currencies.isEmpty,
      emptyMessage: l10n.directoryEmpty,
      itemCount: _currencies.length,
      itemBuilder: (context, index) {
        final currency = _currencies[index];
        final rate = formatDirectoryRate(
          currency.latestNbuRatePerUnit,
          localeName,
        );
        final date = currency.latestRateDate ?? '—';
        final status = currency.isActive
            ? l10n.directoryCurrencyActive
            : l10n.directoryCurrencyInactive;
        return ListTile(
          title: Text(
            '${currency.code} — ${currency.localizedName(languageCode)}',
          ),
          subtitle: Text(
            '${l10n.directoryRatePerUnit}: $rate · '
            '${l10n.directoryRateDate}: $date · $status',
          ),
        );
      },
    );
  }
}
