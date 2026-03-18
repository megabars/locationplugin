import SwiftUI

struct MenuContentView: View {
    @EnvironmentObject var viewModel: LocationViewModel

    var body: some View {
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
        }

        Divider()

        Button("Refresh Now") { viewModel.refresh() }
            .keyboardShortcut("r", modifiers: .command)

        Menu("Refresh Interval") {
            ForEach(LocationViewModel.RefreshInterval.allCases) { interval in
                Button {
                    viewModel.refreshInterval = interval
                } label: {
                    HStack {
                        Text(interval.label)
                        if viewModel.refreshInterval == interval {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }

        Divider()

        Button("Quit") { NSApplication.shared.terminate(nil) }
            .keyboardShortcut("q", modifiers: .command)
    }
}
