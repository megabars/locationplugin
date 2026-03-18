import Foundation

struct IPService: Sendable {
    private struct IPResponse: Decodable {
        let ip: String
    }

    enum IPError: LocalizedError {
        case badStatus(Int)

        var errorDescription: String? {
            switch self {
            case .badStatus(let code): return "IP lookup failed (HTTP \(code))."
            }
        }
    }

    private static let url = URL(string: "https://api.ipify.org?format=json")!
    private static let decoder = JSONDecoder()

    func fetchIP() async throws -> String {
        let (data, response) = try await URLSession.shared.data(from: Self.url)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(statusCode) else {
            throw IPError.badStatus(statusCode)
        }
        return try Self.decoder.decode(IPResponse.self, from: data).ip
    }
}
