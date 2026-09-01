/// Запис довідника країн (ISO-коди та назви трьома мовами).
class CountryReference {
  const CountryReference({
    required this.codeAlpha2,
    required this.codeAlpha3,
    required this.nameUk,
    required this.nameEn,
    required this.nameRu,
  });

  final String codeAlpha2;
  final String codeAlpha3;
  final String nameUk;
  final String nameEn;
  final String nameRu;

  factory CountryReference.fromJson(Map<String, dynamic> json) {
    return CountryReference(
      codeAlpha2: json['codeAlpha2']?.toString() ?? '',
      codeAlpha3: json['codeAlpha3']?.toString() ?? '',
      nameUk: json['nameUk']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      nameRu: json['nameRu']?.toString() ?? '',
    );
  }

  String localizedName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return _fallback(nameEn, nameUk);
      case 'ru':
        return _fallback(nameRu, nameUk);
      default:
        return nameUk;
    }
  }
}

/// Валюта з довідника та останнім курсом НБУ.
class CurrencyReference {
  const CurrencyReference({
    required this.code,
    required this.numericCode,
    required this.nameUk,
    required this.nbuUnits,
    required this.minorUnits,
    required this.isActive,
    this.nameEn,
    this.nameRu,
    this.displayOrder,
    this.latestNbuRatePerUnit,
    this.latestRateDate,
  });

  final String code;
  final int numericCode;
  final String nameUk;
  final String? nameEn;
  final String? nameRu;
  final int nbuUnits;
  final int minorUnits;
  final bool isActive;
  final int? displayOrder;
  final double? latestNbuRatePerUnit;
  final String? latestRateDate;

  factory CurrencyReference.fromJson(Map<String, dynamic> json) {
    return CurrencyReference(
      code: json['code']?.toString() ?? '',
      numericCode: _readInt(json['numericCode']) ?? 0,
      nameUk: json['nameUk']?.toString() ?? '',
      nameEn: json['nameEn']?.toString(),
      nameRu: json['nameRu']?.toString(),
      nbuUnits: _readInt(json['nbuUnits']) ?? 1,
      minorUnits: _readInt(json['minorUnits']) ?? 2,
      isActive: json['isActive'] == true,
      displayOrder: _readInt(json['displayOrder']),
      latestNbuRatePerUnit: _readDouble(json['latestNbuRatePerUnit']),
      latestRateDate: json['latestRateDate']?.toString(),
    );
  }

  String localizedName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return _fallback(nameEn, nameUk);
      case 'ru':
        return _fallback(nameRu, nameUk);
      default:
        return nameUk;
    }
  }
}

/// Один курс НБУ в знімку на дату.
class NbuRate {
  const NbuRate({
    required this.currencyCode,
    required this.rate,
    required this.ratePerUnit,
    required this.nbuUnits,
    this.special,
  });

  final String currencyCode;
  final double rate;
  final double ratePerUnit;
  final int nbuUnits;
  final String? special;

  factory NbuRate.fromJson(Map<String, dynamic> json) {
    return NbuRate(
      currencyCode: json['currencyCode']?.toString() ?? '',
      rate: _readDouble(json['rate']) ?? 0,
      ratePerUnit: _readDouble(json['ratePerUnit']) ?? 0,
      nbuUnits: _readInt(json['nbuUnits']) ?? 1,
      special: json['special']?.toString(),
    );
  }
}

/// Знімок курсів НБУ на конкретну дату.
class NbuRatesSnapshot {
  const NbuRatesSnapshot({
    required this.rateDate,
    required this.fetchedAt,
    required this.rates,
  });

  final String rateDate;
  final String fetchedAt;
  final List<NbuRate> rates;

  factory NbuRatesSnapshot.fromJson(Map<String, dynamic> json) {
    return NbuRatesSnapshot(
      rateDate: json['rateDate']?.toString() ?? '',
      fetchedAt: json['fetchedAt']?.toString() ?? '',
      rates: _readObjectList(json['rates']).map(NbuRate.fromJson).toList(),
    );
  }
}

String _fallback(String? value, String fallback) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return fallback;
  }
  return trimmed;
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

double? _readDouble(Object? value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

List<Map<String, dynamic>> _readObjectList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}
