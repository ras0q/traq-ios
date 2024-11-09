import SwiftUI

package struct URLImage: View {
    private static var imageCache: [URL?: Image] = [:]
    private let url: URL?

    package init(url: URL?) {
        self.url = url
    }

    package init(fileId: String) {
        url = traqServerURL.appending(path: "/files/\(fileId)")
    }

    package init(stampId: String) {
        url = traqServerURL.appending(path: "/stamps/\(stampId)/image")
    }

    package var body: some View {
        if let image = URLImage.imageCache[url] {
            image.resizable()
        } else {
            AsyncImage(url: url) { phase in
                switch phase {
                case let .success(image):
                    image.resizable().task(id: url) {
                        URLImage.imageCache[url] = image
                    }
                case .empty:
                    ProgressView()
                case .failure:
                    Image(systemName: "questionmark").resizable()
                @unknown default:
                    fatalError("unknown phase")
                }
            }
        }
    }
}
