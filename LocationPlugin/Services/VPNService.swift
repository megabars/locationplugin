import Network

struct VPNService: Sendable {
    func statusStream() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                let active = path.availableInterfaces.contains { $0.type == .other }
                continuation.yield(active)
            }
            monitor.start(queue: DispatchQueue(label: "vpn-monitor", qos: .utility))
            continuation.onTermination = { _ in monitor.cancel() }
        }
    }
}
