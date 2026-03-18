import SwiftUI

struct MenuContentView: View {
    @EnvironmentObject var viewModel: LocationViewModel

    var body: some View {
        Label(
            viewModel.isVPNActive ? "VPN: Активен" : "VPN: Выкл",
            systemImage: viewModel.isVPNActive ? "lock.shield.fill" : "lock.shield"
        )
        .foregroundStyle(viewModel.isVPNActive ? .green : .secondary)

        Divider()

        Group {
            switch viewModel.state {
            case .idle, .loading:
                Text("Fetching location…")
                    .foregroundStyle(.secondary)

            case .loaded(let info):
                VStack(alignment: .leading, spacing: 2) {
                    Label(info.query, systemImage: "network")
                        .font(.body.monospacedDigit())
                    Label("\(info.city), \(info.country)", systemImage: "mappin.circle")
                }
                .padding(.vertical, 2)

            case .failed(let message):
                VStack(alignment: .leading, spacing: 2) {
                    Label("Location unavailable", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
                Button("Retry") { viewModel.refresh() }
            }
        }

        Divider()

        if let date = viewModel.lastUpdated {
            Text("Updated \(date, style: .time)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Divider()
        }

        Button("Refresh Now") { viewModel.refresh() }
            .keyboardShortcut("r", modifiers: .command)

        Picker("Refresh Interval", selection: $viewModel.refreshInterval) {
            ForEach(LocationViewModel.RefreshInterval.allCases) { interval in
                Text(interval.label).tag(interval)
            }
        }
        .pickerStyle(.inline)

        Divider()

        Button("Quit") { NSApplication.shared.terminate(nil) }
            .keyboardShortcut("q", modifiers: .command)
    }
}
