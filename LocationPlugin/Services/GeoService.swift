import Foundation

struct GeoService: Sendable {
    private struct GeoResponse: Decodable {
        let status: String
        let country: String
        let countryCode: String
        let city: String
        let query: String
    }

    enum GeoError: LocalizedError {
        case invalidURL
        case badStatus(Int)
        case apiFailed

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Could not build geolocation URL."
            case .badStatus(let code): return "Geolocation lookup failed (HTTP \(code))."
            case .apiFailed: return "Geolocation lookup failed."
            }
        }
    }

    func fetchGeoInfo(for ip: String) async throws -> IPInfo {
        let fields = "status,country,countryCode,city,query"
        let urlString = "http://ip-api.com/json/\(ip)?fields=\(fields)"
        guard let url = URL(string: urlString) else {
            throw GeoError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(statusCode) else {
            throw GeoError.badStatus(statusCode)
        }
        let geoResponse = try JSONDecoder().decode(GeoResponse.self, from: data)
        guard geoResponse.status == "success" else {
            throw GeoError.apiFailed
        }
        return IPInfo(
            country: geoResponse.country,
            countryCode: geoResponse.countryCode,
            city: geoResponse.city,
            query: geoResponse.query
        )
    }
}
