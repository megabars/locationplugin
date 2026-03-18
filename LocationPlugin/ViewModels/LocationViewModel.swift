import Foundation

@MainActor
final class LocationViewModel: ObservableObject {
    @Published private(set) var state: LocationState = .idle
    @Published private(set) var lastUpdated: Date? = nil
    @Published var refreshInterval: RefreshInterval {
        didSet {
            UserDefaults.standard.set(refreshInterval.rawValue, forKey: "refreshInterval")
            restart()
        }
    }

    private let ipService = IPService()
    private let geoService = GeoService()
    private var refreshTask: Task<Void, Never>?

    enum RefreshInterval: Int, CaseIterable, Identifiable {
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
        let saved = UserDefaults.standard.integer(forKey: "refreshInterval")
        refreshInterval = RefreshInterval(rawValue: saved) ?? .oneMinute
        startRefreshLoop()
    }

    deinit {
        refreshTask?.cancel()
    }

    func refresh() {
        restart()
    }

    private func restart() {
        refreshTask?.cancel()
        startRefreshLoop()
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
        // Show loading only on first fetch; keep existing flag during background refresh
        if case .idle = state { state = .loading }

        do {
            let ip = try await ipService.fetchIP()
            let info = try await geoService.fetchGeoInfo(for: ip)
            state = .loaded(info)
            lastUpdated = Date()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
