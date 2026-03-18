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
2. **`LocationViewModel`** (`@MainActor`, `ObservableObject`) — Owns a periodic refresh loop (`Task.sleep`) that calls two services in sequence. Publishes `LocationState` and `lastUpdated`. Persists the chosen `RefreshInterval` to `UserDefaults`.
3. **`IPService`** — Fetches the user's external IP from `https://api.ipify.org?format=json`.
4. **`GeoService`** — Takes an IP, calls `http://ip-api.com/json/{ip}` (plain HTTP — allowed via ATS exception in Info.plist) and returns `IPInfo`.
5. **`IPInfo`** — Decodable model with `status`, `country`, `countryCode`, `city`, `query`.
6. **`LocationState`** — Enum (`idle | loading | loaded(IPInfo) | failed(String)`) with a computed `flagEmoji` property.
7. **`FlagEmoji`** — Converts an ISO 3166-1 alpha-2 country code to a flag emoji using Unicode regional indicator symbols.
8. **`MenuContentView`** — Renders the dropdown: IP/city info, last-updated time, refresh button, refresh-interval picker, quit button.

### Key design decisions

- The app uses **App Sandbox** with only the `network.client` entitlement.
- `ip-api.com` requires plain HTTP — an ATS exception is configured in `Info.plist` for that domain only.
- The refresh loop shows `.loading` state only on the first fetch; subsequent background refreshes keep the previous flag visible to avoid flicker.
- `MenuBarExtra` uses `.menu` style (native NSMenu), not `.window` style.
