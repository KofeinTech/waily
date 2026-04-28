# features/example/

**Demo only — remove when real auth/user features land.**

This feature exists solely to demonstrate the network stack introduced in
WAIL-15: `ApiClient` (thin Dio wrapper), `AuthInterceptor` (refresh-flow),
`LoggingInterceptor`, `AppGateway` exception mapping, and the standard
datasource → repository → entity slice with mapper.

## What's here

- `domain/entities/ping_status.dart` — domain model
- `domain/repositories/ping_repository.dart` — abstract repository
- `data/datasources/ping_api_datasource.dart` — abstract datasource
- `data/datasources/ping_api_datasource_impl.dart` — extends `AppGateway`,
  calls `_apiClient.get('/ping')` inside `safeCall`
- `data/models/ping_response.dart` — Freezed model with `fromJson`
- `data/mappers/ping_response_mapper.dart` — `PingResponse.toEntity()`
- `data/repositories/ping_repository_impl.dart` — composes the datasource
  and mapper

## How to delete

When the first real feature replaces this slice (typically auth or user
profile), the entire folder can be removed in one motion:

```bash
rm -rf lib/features/example/ test/features/example/
```

Then run `fvm flutter pub run build_runner build --delete-conflicting-outputs`
to regenerate `injection.config.dart` without the example bindings.
