# Architectural State & Token Optimization Reference

> **Purpose**: This living markdown document provides a high-density, comprehensive map of the application architecture, dependency injection graph, routes, storage schema, environment setups, and active features. It ensures subsequent AI agent turns or developer sessions have full context without re-reading multiple source files.

---

## 1. System Overview & Tech Stack

| Layer / Concern | Technology / Library | Purpose / Implementation Detail |
|---|---|---|
| **Architecture Pattern** | Feature-First Clean Architecture | Features isolated into `data`, `domain`, `presentation` |
| **API Provider** | [FakeStore API](https://fakestoreapi.com) | E-commerce products, categories, pricing, and ratings |
| **Networking** | `retrofit: ^4.1.0` + `dio: ^5.4.1` | Typed API clients, automatic deserialization |
| **Network Logging** | `logger: ^2.2.0` via `DioLoggingInterceptor` | Formatted console output of Method, URL, Headers, Body, Responses, & Errors |
| **Offline Storage** | `hive: ^2.2.3` + `hive_flutter: ^1.1.0` | High-performance NoSQL offline caching with TypeAdapters |
| **Offline Sync Policy** | Offline-First (Cache $\rightarrow$ Remote $\rightarrow$ Update) | Fallback to cache on network drop / offline mode |
| **State Management** | `provider: ^6.1.2` (`ChangeNotifier`) | Reactive UI state, category filter, search, sync status |
| **Dependency Injection** | `get_it: ^7.6.7` | Service locator registered in `injection_container.dart` |
| **Navigation** | `go_router: ^13.2.0` | Declarative routing with URL parameter parsing (`/products/:id`) |
| **Environment Separation**| `--dart-define-from-file` + `AppConfig` | Secure separation of `dev` and `live` configs |
| **IDE Run Profiles** | `.vscode/launch.json` | Dedicated Dev, Live, and Release launch configurations |

---

## 2. Directory Tree

```
lib/
├── app.dart                                # MultiProvider + MaterialApp.router setup
├── main.dart                               # Default entry point (environment-driven)
├── main_dev.dart                           # Dedicated Dev entry point
├── main_live.dart                          # Dedicated Live / Production entry point
├── core/
│   ├── config/
│   │   ├── app_config.dart                 # Secure environment config & constants
│   │   └── environment.dart                # dev | live enum
│   ├── constants/
│   │   ├── api_constants.dart              # FakeStore API endpoints
│   │   └── storage_keys.dart               # Hive box names
│   ├── di/
│   │   └── injection_container.dart        # GetIt service locator setup
│   ├── errors/
│   │   ├── exceptions.dart                 # AppException, ServerException, CacheException
│   │   └── failures.dart                   # Failure, ServerFailure, CacheFailure
│   ├── network/
│   │   ├── api_client.dart                 # Retrofit @RestApi client definition
│   │   ├── api_client.g.dart               # Retrofit generated client
│   │   └── dio_logging_interceptor.dart    # Logger-powered Dio request/response logger
│   ├── router/
│   │   └── app_router.dart                 # GoRouter route declarations
│   ├── storage/
│   │   └── hive_service.dart               # Hive initialization and box provider
│   ├── theme/
│   │   └── app_theme.dart                  # Indigo/Teal/Slate modern dark & light theme
│   └── utils/
│       └── app_logger.dart                 # Static pretty printer logger
└── features/
    └── products/
        ├── data/
        │   ├── datasources/
        │   │   ├── product_local_datasource.dart   # Hive CRUD operations
        │   │   └── product_remote_datasource.dart  # FakeStore API calls via Retrofit
        │   ├── models/
        │   │   ├── product_hive_model.dart         # Hive TypeAdapter (typeId: 0)
        │   │   ├── product_hive_model.g.dart       # Generated Hive adapter
        │   │   ├── product_model.dart              # JSON DTO (fromJson/toJson)
        │   └── repositories/
        │       └── product_repository_impl.dart    # Offline-first caching logic
        ├── domain/
        │   ├── entities/
        │   │   └── product_entity.dart             # Core business model
        │   └── repositories/
        │       └── product_repository.dart         # Repository interface contract
        └── presentation/
            ├── providers/
            │   └── product_provider.dart           # State management & connectivity listener
            ├── screens/
            │   ├── product_detail_screen.dart      # Single product detail view
            │   └── product_list_screen.dart        # Grid, search, categories, sync badges
            └── widgets/
                ├── category_chip.dart              # Category filter chip
                ├── connectivity_banner.dart        # Offline / Warning status bar
                ├── product_card.dart               # Polished product card with image & price
                └── sync_status_badge.dart          # Live / Cache / Offline pill indicator
```

---

## 3. Environment Separation & Security

- **Compile-Time Isolation**: All environment settings are managed via `AppConfig` and loaded securely through `--dart-define-from-file`.
- **Configuration Files**:
  - `config/dev.json`: `{"APP_ENV": "dev", "APP_NAME": "FakeStore App (Dev)", "API_BASE_URL": "https://fakestoreapi.com"}`
  - `config/live.json`: `{"APP_ENV": "live", "APP_NAME": "FakeStore App Live", "API_BASE_URL": "https://fakestoreapi.com"}`
- **VS Code Launch Profiles** (`.vscode/launch.json`):
  - `POC App (Dev)` $\rightarrow$ `lib/main_dev.dart` (`--dart-define-from-file=config/dev.json`)
  - `POC App (Live / Production)` $\rightarrow$ `lib/main_live.dart` (`--dart-define-from-file=config/live.json`)
  - `POC App (Dev - Release)` & `POC App (Live - Release)`

---

## 4. API & Network Logging Flow

- **Base URL**: `https://fakestoreapi.com`
- **Endpoints**:
  - `GET /products`
  - `GET /products/{id}`
  - `GET /products/categories`
  - `GET /products/category/{category}`
- **Logging**: `DioLoggingInterceptor` intercepts all outbound requests and inbound responses, outputting to console with formatted JSON indentation and emojis (`➡️ [REQUEST]`, `⬅️ [RESPONSE]`, `❌ [ERROR]`). Enabled in Dev, disabled in Live.

---

## 5. Offline-First Storage & Cache Flow

1. **Local First**: Screen loads $\rightarrow$ reads `ProductLocalDataSource.getCachedProducts()` $\rightarrow$ displays UI instantly if cache is present.
2. **Online Sync**: If online, `ProductRemoteDataSource` fetches latest products from FakeStore API $\rightarrow$ writes to Hive box `products_box` $\rightarrow$ emits fresh data.
3. **Offline Fallback**: If network is unavailable or request fails, falls back gracefully to Hive cache with `isOffline = true` and `isFromCache = true`.
4. **Auto Sync**: `Connectivity.onConnectivityChanged` automatically triggers a background refresh when network connection is restored.

---

## 6. Route Registry (GoRouter)

| Route Path | Name | Target Screen | Parameters / Arguments |
|---|---|---|---|
| `/` | `products` | `ProductListScreen` | None |
| `/products/:id` | `product-details` | `ProductDetailScreen` | `:id` (Integer product ID) |

---

## 7. Verification Status

- **Static Analysis**: `dart analyze` $\rightarrow$ `No issues found!` (0 errors, 0 warnings).
- **Automated Tests**: `flutter test` $\rightarrow$ `8/8 tests passed` (Environment config tests, JSON serialization tests, Model conversion tests, Widget smoke tests).
