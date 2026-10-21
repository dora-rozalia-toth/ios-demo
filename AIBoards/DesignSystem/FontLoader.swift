import CoreText
import Foundation

/// Registers the bundled Atlas typefaces (Plus Jakarta Sans + Merriweather) with
/// CoreText at launch, so no Info.plist `UIAppFonts` entry is required. Runtime
/// registration keeps the project file free of per-font bookkeeping.
enum FontLoader {
    private static var registered = false

    static func registerFonts() {
        guard !registered else { return }
        registered = true

        let names = [
            "PlusJakartaSans",
            "PlusJakartaSans-Medium",
            "PlusJakartaSans-SemiBold",
            "PlusJakartaSans-Bold",
            "Merriweather-Regular",
        ]
        for name in names {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                #if DEBUG
                print("[FontLoader] missing font resource: \(name).ttf")
                #endif
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                #if DEBUG
                print("[FontLoader] could not register \(name): \(String(describing: error))")
                #endif
            }
        }
    }
}
