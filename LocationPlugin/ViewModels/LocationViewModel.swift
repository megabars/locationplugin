import Foundation

@MainActor
final class LocationViewModel: ObservableObject {
    @Published private(set) var state: LocationState = .idle
    @Published private(set) var lastUpdated: Date? = nil
    @Published var refreshInterval: RefreshInterval {
        didSet {
            UserDefaults.standard.set(refreshInterval.rawValue, forKey: Self.refreshIntervalKey)
            restart()
        }
    }

    private static let refreshIntervalKey = "refreshInterval"

    @Published private(set) var isVPNActive: Bool = false

    private let ipService = IPService()
    private let geoService = GeoService()
    private let vpnService = VPNService()
    private var refreshTask: Task<Void, Never>?
    private var vpnTask: Task<Void, Never>?
    private var vpnDebounceTask: Task<Void, Never>?
    private var generation = 0

    enum RefreshInterval: Int, CaseIterable, Identifiable, Sendable {
        case thirtySeconds = 30
        case oneMinute = 60
        case fiveMinutes = 300
        case tenMinutes = 600
        case thirtyMinutes = 1800

        var id: Int { rawValue }

        var label: String {
            switch self {
            case .thirtySeconds: return "30 seconds"
            case .oneMinute:     return "1 minute"
            case .fiveMinutes:   return "5 minutes"
            case .tenMinutes:    return "10 minutes"
            case .thirtyMinutes: return "30 minutes"
            }
        }
    }

    init() {
        let saved = UserDefaults.standard.integer(forKey: Self.refreshIntervalKey)
        _refreshInterval = Published(wrappedValue: RefreshInterval(rawValue: saved) ?? .oneMinute)
        startRefreshLoop()
        startVPNMonitor()
    }

    func refresh() {
        restart()
    }

    private func restart() {
        generation += 1
        refreshTask?.cancel()
        startRefreshLoop()
    }

    private func startVPNMonitor() {
        vpnTask = Task {
            for await active in vpnService.statusStream() {
                let previous = isVPNActive
                isVPNActive = active
                if previous != active {
                    // Debounce: NWPathMonitor fires many times during a single
                    // network transition; wait 500 ms before reacting.
                    vpnDebounceTask?.cancel()
                    vpnDebounceTask = Task {
                        try? await Task.sleep(for: .milliseconds(500))
                        guard !Task.isCancelled else { return }
                        restart()
                    }
                }
            }
        }
    }

    private func startRefreshLoop() {
        let interval = refreshInterval
        refreshTask = Task {
            while !Task.isCancelled {
                await fetchAndUpdate()
                try? await Task.sleep(for: .seconds(interval.rawValue))
            }
        }
    }

    private func fetchAndUpdate() async {
        // Show loading on first fetch or after failure; keep existing flag during background refresh
        if case .idle = state { state = .loading }
        if case .failed = state { state = .loading }

        let gen = generation
        do {
            let ip = try await ipService.fetchIP()
            let info = try await geoService.fetchGeoInfo(for: ip)
            // Discard result if a newer fetch was already started (restart was called
            // while this request was in-flight).
            guard gen == generation else { return }
            state = .loaded(info)
            lastUpdated = Date()
        } catch is CancellationError {
            // Task was cancelled (e.g. refresh interval changed), don't update state
        } catch {
            guard gen == generation else { return }
            state = .failed(error.localizedDescription)
        }
    }
}
