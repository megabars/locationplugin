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

    func fetchIP() async throws -> String {
        let url = URL(string: "https://api.ipify.org?format=json")!
        let (data, response) = try await URLSession.shared.data(from: url)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(statusCode) else {
            throw IPError.badStatus(statusCode)
        }
        return try JSONDecoder().decode(IPResponse.self, from: data).ip
    }
}
