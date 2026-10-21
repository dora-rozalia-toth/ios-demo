import CoreGraphics

extension DS {
    /// Atlas Core spacing scale (8-pt based).
    enum Space {
        static let xxs: CGFloat = 2    // 0.25
        static let xs: CGFloat = 4     // 0.5
        static let sm: CGFloat = 8     // 1
        static let smd: CGFloat = 12   // 1.5
        static let md: CGFloat = 16    // 2
        static let mdl: CGFloat = 20   // 2.5
        static let lg: CGFloat = 24    // 3
        static let xl: CGFloat = 32    // 4
        static let xxl: CGFloat = 40   // 5
        static let xxxl: CGFloat = 48  // 6
    }

    /// Atlas Semantic/Radius scale.
    enum Radius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let lg16: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 36
        static let full: CGFloat = 9999
    }
}
