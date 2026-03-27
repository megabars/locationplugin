# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

This is an Xcode project (no SPM Package.swift). Build via Xcode or `xcodebuild`:

```bash
xcodebuild -project LocationPlugin.xcodeproj -scheme LocationPlugin -configuration Debug build
```

There are no tests, linter, or formatter configured in this project.

## Architecture

LocationPlugin is a **macOS menu-bar-only app** that shows the user's country flag (derived from their external IP address) in the macOS menu bar. It is a pure SwiftUI app with no AppKit window — `LSUIElement` is set to `true` in Info.plist so it has no Dock icon.

### Data flow

1. **`LocationPluginApp`** — `@main` entry point. Uses `MenuBarExtra` (menu style, not window) with `LocationViewModel` as `@StateObject`. The menu bar label is driven by `viewModel.state.flagEmoji`.
2. **`LocationViewModel`** (`@MainActor`, `ObservableObject`) — Owns a periodic refresh loop (`Task.sleep`) that calls two services in sequence. Publishes `LocationState`, `lastUpdated`, `isVPNActive`, and `launchAtLogin`. Persists the chosen `RefreshInterval` to `UserDefaults`. Manages launch-at-login via `SMAppService.mainApp`.
3. **`IPService`** — Fetches the user's external IP from `https://api.ipify.org?format=json`.
4. **`GeoService`** — Takes an IP, calls `http://ip-api.com/json/{ip}?fields=status,country,countryCode,city,query` (plain HTTP — allowed via ATS exception in Info.plist) and returns `IPInfo`. Both services are `struct` + `Sendable`.
5. **`VPNService`** — Uses `NWPathMonitor` to stream a `Bool` via `AsyncStream<Bool>` indicating whether a VPN interface (`utun*`, `ipsec*`, `ppp*`) is active. `LocationViewModel` subscribes on init, debounces transitions (500 ms), and triggers a refresh on change. VPN status is shown in the menu as a lock-shield icon.
6. **`IPInfo`** — Decodable model with `status`, `country`, `countryCode`, `city`, `query`.
7. **`LocationState`** — Enum (`idle | loading | loaded(IPInfo) | failed(String)`) with a computed `flagEmoji` property.
8. **`FlagEmoji`** — Converts an ISO 3166-1 alpha-2 country code to a flag emoji using Unicode regional indicator symbols.
9. **`MenuContentView`** — Renders the dropdown via `@EnvironmentObject var viewModel`: VPN status indicator, IP/city info, last-updated time, refresh button (`⌘R`), refresh-interval picker, quit button (`⌘Q`).

### Key design decisions

- The app uses **App Sandbox** with only the `network.client` entitlement.
- `ip-api.com` requires plain HTTP — an ATS exception is configured in `Info.plist` for that domain only.
- The refresh loop shows `.loading` state only on the first fetch; subsequent background refreshes keep the previous flag visible to avoid flicker.
- `MenuBarExtra` uses `.menu` style (native NSMenu), not `.window` style.
- Launch-at-login uses `SMAppService.mainApp` (macOS 13+ API). On first enable, macOS may prompt the user to confirm in System Settings → General → Login Items. The toggle reads actual status back from `SMAppService` after each call to stay in sync.
