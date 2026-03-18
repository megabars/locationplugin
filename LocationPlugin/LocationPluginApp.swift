import SwiftUI

@main
struct LocationPluginApp: App {
    @StateObject private var viewModel = LocationViewModel()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView()
                .environmentObject(viewModel)
        } label: {
            Text(viewModel.state.flagEmoji)
        }
        .menuBarExtraStyle(.menu)
    }
}
