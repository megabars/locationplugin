import Foundation

struct GeoService: Sendable {
    private struct GeoResponse: Decodable {
        let status: String
        let country: String?
        let countryCode: String?
        let city: String?
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

    private static let decoder = JSONDecoder()

    func fetchGeoInfo(for ip: String) async throws -> IPInfo {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "ip-api.com"
        guard let encodedIP = ip.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw GeoError.invalidURL
        }
        components.path = "/json/\(encodedIP)"
        components.queryItems = [URLQueryItem(name: "fields", value: "status,country,countryCode,city,query")]
        guard let url = components.url else {
            throw GeoError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(statusCode) else {
            throw GeoError.badStatus(statusCode)
        }
        let geoResponse = try Self.decoder.decode(GeoResponse.self, from: data)
        guard geoResponse.status == "success",
              let country = geoResponse.country,
              let countryCode = geoResponse.countryCode,
              let city = geoResponse.city else {
            throw GeoError.apiFailed
        }
        return IPInfo(
            country: country,
            countryCode: countryCode,
            city: city,
            query: geoResponse.query
        )
    }
}
