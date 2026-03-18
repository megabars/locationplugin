struct IPInfo: Decodable, Equatable {
    let status: String
    let country: String
    let countryCode: String
    let city: String
    let query: String
}
