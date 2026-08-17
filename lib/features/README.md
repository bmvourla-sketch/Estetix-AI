# Features

This project follows **Clean Architecture with a feature-first layout**:

```
lib/features/<feature>/
├── data/
│   ├── datasources/      # Remote API clients, local DB, preferences…
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Plain data models
│   ├── repositories/     # Abstract repository contracts
│   └── usecases/         # Single-purpose business operations
└── presentation/
    ├── providers/        # ChangeNotifier state (UI state)
    ├── pages/            # Screens
    └── widgets/          # Feature-specific widgets
```

Rules of thumb:

- `domain` never imports Flutter/UI code or `data`; it only depends on pure Dart.
- `data` implements the contracts defined in `domain`.
- `presentation` talks to `domain` through use cases (or providers), never directly to
  `data`.
- Cross-feature / shared code lives in `lib/core/` (widgets, localization, DI,
  constants). App-wide configuration lives in `lib/app/` (theme, root widget).

To add a new feature, create a folder under `lib/features/` following the
structure above, then register its dependencies in
`lib/core/di/service_locator.dart`.
