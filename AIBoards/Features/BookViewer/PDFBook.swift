import SwiftUI
import UIKit
import PDFKit

/// Loads the bundled sample PDF and renders pages to images on demand (cached).
@MainActor
final class PDFBook: ObservableObject {
    static let shared = PDFBook()

    let doc: PDFDocument?
    private var cache: [Int: UIImage] = [:]
    private let renderWidth: CGFloat = 820   // points; Image scales to fit the column

    var pageCount: Int { doc?.pageCount ?? 0 }

    init() {
        if let url = Bundle.main.url(forResource: "the-basics-of-ux-design", withExtension: "pdf") {
            doc = PDFDocument(url: url)
        } else {
            doc = nil
        }
    }

    /// Aspect ratio (height / width) of a page, for sizing the placeholder.
    func aspect(_ index: Int) -> CGFloat {
        guard let page = doc?.page(at: index) else { return 1.414 }
        let b = page.bounds(for: .mediaBox)
        return b.height / max(1, b.width)
    }

    func image(_ index: Int) -> UIImage? {
        if let cached = cache[index] { return cached }
        guard let page = doc?.page(at: index) else { return nil }
        let b = page.bounds(for: .mediaBox)
        let scale = renderWidth / b.width
        let size = CGSize(width: renderWidth, height: b.height * scale)
        let img = UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor.white.set()
            ctx.fill(CGRect(origin: .zero, size: size))
            let cg = ctx.cgContext
            cg.translateBy(x: 0, y: size.height)
            cg.scaleBy(x: scale, y: -scale)
            page.draw(with: .mediaBox, to: cg)
        }
        cache[index] = img
        return img
    }
}

/// A single PDF page, rendered off the first appearance and shown on a white card.
struct PDFPageView: View {
    @ObservedObject var book: PDFBook
    let index: Int
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Rectangle().fill(DS.ColorToken.surfaceSubtle)
                    .aspectRatio(1 / book.aspect(index), contentMode: .fit)
                    .overlay(ProgressView())
            }
        }
        .frame(maxWidth: .infinity)
        .background(.white)
        .overlay(Rectangle().stroke(DS.ColorToken.border, lineWidth: 1))
        .task(id: index) {
            if image == nil { image = book.image(index) }
        }
    }
}
