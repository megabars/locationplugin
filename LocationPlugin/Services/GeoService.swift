import Foundation

struct GeoService {
    func fetchGeoInfo(for ip: String) async throws -> IPInfo {
        let fields = "status,country,countryCode,city,query"
        let urlString = "http://ip-api.com/json/\(ip)?fields=\(fields)"
        let url = URL(string: urlString)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let info = try JSONDecoder().decode(IPInfo.self, from: data)
        guard info.status == "success" else {
            throw GeoError.apiFailed
        }
        return info
    }

    enum GeoError: LocalizedError {
        case apiFailed
        var errorDescription: String? { "Geolocation lookup failed." }
    }
}
