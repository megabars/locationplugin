enum FlagEmoji {
    static func flag(for countryCode: String) -> String {
        let code = countryCode.uppercased()
        guard code.count == 2,
              code.unicodeScalars.allSatisfy({ $0.value >= 65 && $0.value <= 90 })
        else { return "🌐" }

        let base: UInt32 = 0x1F1E6
        return code.unicodeScalars
            .compactMap { UnicodeScalar(base + $0.value - 65) }
            .map { String($0) }
            .joined()
    }
}
