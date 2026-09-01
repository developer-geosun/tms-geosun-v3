import 'package:intl/intl.dart';

import '../../../core/http/api_error.dart';
import '../../../core/l10n/app_localizations.dart';

/// Повідомлення про помилку завантаження довідника.
String directoryErrorMessage(ApiException error, AppLocalizations l10n) {
  if (error.statusCode == 403) {
    return l10n.directoryAccessDenied;
  }
  return l10n.directoryLoadFailed;
}

String directoryRatesErrorMessage(ApiException error, AppLocalizations l10n) {
  if (error.statusCode == 403) {
    return l10n.directoryAccessDenied;
  }
  return l10n.directoryRatesLoadFailed;
}

/// 404/422 — курсів ще немає, показуємо порожній стан замість помилки.
bool isMissingNbuRates(ApiException error) {
  return error.statusCode == 404 || error.statusCode == 422;
}

/// Форматування курсу як у Angular-довіднику валют.
String formatDirectoryRate(double? value, String localeName) {
  if (value == null) {
    return '—';
  }
  final format = NumberFormat.decimalPattern(localeName)
    ..minimumFractionDigits = 2
    ..maximumFractionDigits = 6;
  return format.format(value);
}

String formatDirectoryFetchedAt(String iso, String localeName) {
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) {
    return iso.isEmpty ? '—' : iso;
  }
  return DateFormat.yMd(localeName).add_Hm().format(parsed.toLocal());
}

String formatDirectoryIsoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
