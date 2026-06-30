# Parcel Tracking — Project Structure

A Flutter app organised by responsibility. This document is the map: what each
folder is for, the conventions to follow, and how to add new pieces.

## Tech & conventions at a glance

| Concern          | Choice                | Where it lives                         |
| ---------------- | --------------------- | -------------------------------------- |
| State management | **Provider** (`ChangeNotifier`) | `lib/providers/`, wired in `main.dart` |
| Navigation       | **GetX** (`GetMaterialApp`, named routes) | `lib/routes/`            |
| Typography       | **google_fonts**      | `lib/utils/app_fonts.dart`, `lib/theme/` |
| Theming          | Light/dark `ColorScheme` | `lib/theme/app_theme.dart`          |
| Networking       | `http`                | `lib/services/api_service.dart`        |
| Persistence      | `shared_preferences`  | `lib/services/storage_service.dart`    |
| Build config     | `--dart-define`       | `lib/config/`, `lib/utils/constants.dart` |

**Division of labour:** Provider owns app **state**; GetX is used for
**navigation** and context-free helpers (`Get.toNamed`, `Get.back`,
`Get.snackbar`, `Get.dialog`). They don't overlap — keep state in providers, not
in GetX controllers, unless a specific case calls for it.

## Directory layout

```
lib/
├── main.dart              # Entry point: init storage, MultiProvider, GetMaterialApp
├── config/               # Compile-time configuration & flavor switches
│   └── app_config.dart   #   app name, APP_ENV (dev/staging/prod)
├── models/               # Plain data classes / DTOs (fromJson / toJson)
├── providers/            # State — ChangeNotifier classes (Provider)
│   └── theme_provider.dart
├── routes/               # GetX navigation
│   ├── app_routes.dart   #   route-name constants
│   └── app_pages.dart    #   GetPage table + initial route
├── screens/              # Full-page UI (one widget per screen)
│   └── home_screen.dart
├── services/             # External integrations / IO
│   ├── api_service.dart  #   JSON HTTP client + ApiException
│   └── storage_service.dart  # SharedPreferences wrapper
├── theme/                # ColorSchemeS + ThemeData builders
│   └── app_theme.dart
├── utils/                # Cross-cutting helpers & constants
│   ├── app_fonts.dart    #   Google Fonts access (text theme + helpers)
│   └── constants.dart    #   API base URL, timeouts (via --dart-define)
└── widgets/              # Reusable presentational widgets

assets/
└── images/               # Image assets (declared in pubspec.yaml)

reference_project/        # Read-only reference app — excluded from analysis
```

## Layer responsibilities

- **`config/`** — Values fixed at build time (`String.fromEnvironment`). Use for
  flavor/environment switches so one codebase produces dev/prod binaries.
- **`models/`** — Pure Dart data classes. No Flutter or UI imports. One model per
  file (`user.dart` → `class User`).
- **`providers/`** — App state as `ChangeNotifier`s. Each is registered in the
  `MultiProvider` in `main.dart` and read in widgets via
  `context.watch<T>()` / `context.read<T>()`.
- **`routes/`** — All navigation wiring. Route names are constants
  (`AppRoutes`); the `GetPage` table (`AppPages`) maps names to screens.
- **`screens/`** — Top-level pages. Compose `widgets/` and read `providers/`.
- **`services/`** — Anything that talks to the outside world (HTTP, storage,
  platform). Keep raw `http`/`SharedPreferences` calls out of the UI.
- **`theme/`** — Centralised light/dark themes. Swap the `ColorScheme`s to
  rebrand the whole app.
- **`utils/`** — Stateless helpers and constants shared everywhere.
- **`widgets/`** — Reusable, presentational widgets used by more than one screen.

## How to…

### Add a screen + route
1. Create `lib/screens/profile_screen.dart` → `class ProfileScreen`.
2. Add a name in `lib/routes/app_routes.dart`:
   `static const String profile = '/profile';`
3. Register it in `lib/routes/app_pages.dart`:
   `GetPage(name: AppRoutes.profile, page: () => const ProfileScreen())`.
4. Navigate: `Get.toNamed(AppRoutes.profile);`

### Add a provider (state)
1. Create `lib/providers/foo_provider.dart` extending `ChangeNotifier`; call
   `notifyListeners()` on change.
2. Register it in `main.dart`:
   `ChangeNotifierProvider(create: (_) => FooProvider())`.
3. Read in a widget: `context.watch<FooProvider>()` (rebuilds) or
   `context.read<FooProvider>()` (one-off).

### Call the API
Use `ApiService` (don't call `http` directly from the UI):
```dart
final data = await ApiService().get('/me');
```
It attaches the auth token from `StorageService` and throws `ApiException` on
non-2xx responses.

### Persist a value
Add a key constant in `StorageService`, then
`StorageService.setString(StorageService.kMyKey, value)`.
`StorageService.init()` is already awaited in `main()`.

### Restyle type or theme
- Font family: change `inter` in `lib/utils/app_fonts.dart`.
- Colors: edit the schemes in `lib/theme/app_theme.dart`.

## Running

```bash
flutter pub get
flutter run

# With environment overrides:
flutter run \
  --dart-define=APP_ENV=prod \
  --dart-define=API_BASE_URL=https://api.sendthis.app
```