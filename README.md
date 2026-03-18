# LocationPlugin

A lightweight macOS menu bar app that shows the country flag of your current external IP address.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange)

## What it does

LocationPlugin sits in your menu bar and displays a flag emoji corresponding to the country your external IP address is geolocated to. Click the flag to see details.

| State | Menu bar icon |
|---|---|
| Starting up | 🌐 |
| Located | country flag, e.g. 🇺🇸 🇩🇪 🇯🇵 |
| Error | ⚠️ |

## Features

- **Country flag in the menu bar** — updates automatically in the background
- **Dropdown with details** — external IP address, city, country
- **Error visible in the panel** — ⚠️ appears directly in the menu bar on failure, with a Retry button
- **Configurable refresh interval** — 30 s / 1 min / 5 min / 10 min / 30 min (default: 1 minute), persisted across restarts
- **No Dock icon** — runs silently in the background
- **No third-party dependencies** — pure Swift + SwiftUI

## Requirements

- macOS 13 Ventura or later
- Xcode 15 or later (to build from source)

## Build & Run

```bash
git clone https://github.com/megabars/locationplugin.git
cd locationplugin
xcodebuild -project LocationPlugin.xcodeproj -scheme LocationPlugin -configuration Debug build
open ~/Library/Developer/Xcode/DerivedData/LocationPlugin-*/Build/Products/Debug/LocationPlugin.app
```

Or open `LocationPlugin.xcodeproj` in Xcode and press **⌘R**.

## How it works

1. Fetches your external IP from [ipify.org](https://api.ipify.org)
2. Geolocates it via [ip-api.com](http://ip-api.com)
3. Converts the ISO 3166-1 alpha-2 country code to a flag emoji using Unicode Regional Indicator Symbols
4. Repeats on the configured interval

The app uses App Sandbox with only the `network.client` entitlement.

## Privacy

No data is stored or transmitted beyond the two API calls needed to determine your location:
- `https://api.ipify.org` — returns your public IP
- `http://ip-api.com` — returns the country/city for that IP

## License

MIT
