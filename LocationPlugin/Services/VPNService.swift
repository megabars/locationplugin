import Network

struct VPNService: Sendable {
    func statusStream() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                // Only treat utun/ipsec/ppp interfaces as VPN; .other also covers
                // Bluetooth PAN, USB tethering, Thunderbolt Bridge, etc.
                let active = path.availableInterfaces.contains { iface in
                    iface.type == .other && (
                        iface.name.hasPrefix("utun") ||
                        iface.name.hasPrefix("ipsec") ||
                        iface.name.hasPrefix("ppp")
                    )
                }
                continuation.yield(active)
            }
            monitor.start(queue: DispatchQueue(label: "vpn-monitor", qos: .utility))
            continuation.onTermination = { _ in monitor.cancel() }
        }
    }
}
