enum LocationState {
    case idle
    case loading
    case loaded(IPInfo)
    case failed(String)

    var flagEmoji: String {
        switch self {
        case .idle:
            return "🌐"
        case .loading:
            return "🌐"
        case .loaded(let info):
            return FlagEmoji.flag(for: info.countryCode)
        case .failed:
            return "⚠️"
        }
    }
}
