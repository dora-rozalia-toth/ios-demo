import SwiftUI

@main
struct AIBoardsApp: App {
    init() {
        FontLoader.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppShell()
                .preferredColorScheme(.light)
        }
    }
}
