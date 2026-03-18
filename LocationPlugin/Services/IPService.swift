import Foundation

struct IPService {
    private struct IPResponse: Decodable {
        let ip: String
    }

    func fetchIP() async throws -> String {
        let url = URL(string: "https://api.ipify.org?format=json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(IPResponse.self, from: data).ip
    }
}
