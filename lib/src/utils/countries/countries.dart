/// Country, State, and City data layer for CommonDesigns.
///
/// Exports:
/// - [Country] — rich country model
/// - [CountryState] — state/region model
/// - [CountryCity] — city model
/// - [CountryResult] — typed result wrapper
/// - [CountryData] — static lazy-loaded country list + lookup maps
/// - [CountryService] — source-switchable service (static / REST API)
/// - [CountrySource] — enum to pick data source
/// - [CountryHttpClient] — interface to inject your own HTTP client
/// - [CountryServiceException] — thrown on service errors
library;

export 'country_model.dart';
export 'country_data.dart';
export 'country_service.dart';