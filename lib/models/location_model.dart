import 'dart:convert';

/// Model data lokasi hasil Open-Meteo Geocoding API maupun penyimpanan lokal.
class LocationModel {
  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country = '',
    this.countryCode = '',
    this.admin1 = '',
    this.admin2 = '',
    this.timezone = 'auto',
    this.elevation,
    this.population,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String countryCode;
  final String admin1;
  final String admin2;
  final String timezone;
  final double? elevation;
  final int? population;

  /// Membuat instance [LocationModel] dari JSON respons Open-Meteo Geocoding API.
  factory LocationModel.fromGeocodingJson(Map<String, dynamic> json) {
    final lat = (json['latitude'] as num).toDouble();
    final lon = (json['longitude'] as num).toDouble();
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ??
          Object.hash(json['name'], lat.toStringAsFixed(4), lon.toStringAsFixed(4)),
      name: (json['name'] as String?)?.trim() ?? 'Lokasi Tidak Diketahui',
      latitude: lat,
      longitude: lon,
      country: (json['country'] as String?)?.trim() ?? '',
      countryCode: (json['country_code'] as String?)?.trim() ?? '',
      admin1: (json['admin1'] as String?)?.trim() ?? '',
      admin2: (json['admin2'] as String?)?.trim() ?? '',
      timezone: (json['timezone'] as String?)?.trim().isNotEmpty == true
          ? (json['timezone'] as String).trim()
          : 'auto',
      elevation: (json['elevation'] as num?)?.toDouble(),
      population: (json['population'] as num?)?.toInt(),
    );
  }

  /// Membuat instance [LocationModel] dari JSON yang disimpan di Local Storage.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: (json['country'] as String?) ?? '',
      countryCode: (json['countryCode'] as String?) ?? '',
      admin1: (json['admin1'] as String?) ?? '',
      admin2: (json['admin2'] as String?) ?? '',
      timezone: (json['timezone'] as String?) ?? 'auto',
      elevation: (json['elevation'] as num?)?.toDouble(),
      population: (json['population'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'countryCode': countryCode,
      'admin1': admin1,
      'admin2': admin2,
      'timezone': timezone,
      'elevation': elevation,
      'population': population,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory LocationModel.fromJsonString(String raw) {
    return LocationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Label wilayah administratif dan negara untuk subjudul lokasi.
  String get subtitle {
    final parts = <String>[
      if (admin1.isNotEmpty && admin1.toLowerCase() != name.toLowerCase())
        admin1,
      if (country.isNotEmpty) country,
    ];
    return parts.join(', ');
  }

  /// Format koordinat lintang dan bujur yang mudah dibaca.
  String get formattedCoordinates {
    final latDir = latitude >= 0 ? 'LU' : 'LS';
    final lonDir = longitude >= 0 ? 'BT' : 'BB';
    return '${latitude.abs().toStringAsFixed(2)}° $latDir, '
        '${longitude.abs().toStringAsFixed(2)}° $lonDir';
  }

  /// Kunci unik lokasi berdasarkan ID atau koordinat terbulatkan.
  String get uniqueKey =>
      '$id:${latitude.toStringAsFixed(3)}:${longitude.toStringAsFixed(3)}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.id == id &&
        (other.latitude - latitude).abs() < 0.001 &&
        (other.longitude - longitude).abs() < 0.001;
  }

  @override
  int get hashCode => Object.hash(
        id,
        latitude.toStringAsFixed(3),
        longitude.toStringAsFixed(3),
      );
}
