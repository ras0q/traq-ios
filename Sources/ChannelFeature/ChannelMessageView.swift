import ComposableArchitecture
import MarkdownFeature
import SwiftUI
import TraqAPI

struct ChannelMessageView: View {
    let message: Components.Schemas.Message
    let user: Components.Schemas.User
    let stamps: [Components.Schemas.StampWithThumbnail]

    var body: some View {
        HStack(alignment: .top) {
            UserIcon(iconFileId: user.iconFileId)
                .frame(width: 40, height: 40, alignment: .leading)
            VStack (alignment: .leading) {
                HStack {
                    Text(user.displayName).bold()
                    Text("@\(user.name)").font(.callout).foregroundStyle(Color.gray)
                }
                Markdown("\(message.content)", stamps: stamps)
            }
        }
    }
}

package struct UserIcon: View {
    private static var iconImageDictionary: [URL?: Image] = [:]

    private let iconUrl: URL?

    package init(iconFileId: String) {
        iconUrl = traqServerURL.appending(path: "/files/\(iconFileId)")
    }

    package var body: some View {
        if let image = UserIcon.iconImageDictionary[iconUrl] {
            image
                .resizable()
                .clipShape(Circle())
        } else {
            AsyncImage(url: iconUrl) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .clipShape(Circle())
                        .task(id: iconUrl) {
                            UserIcon.iconImageDictionary[iconUrl] = image
                        }
                case .empty:
                    ProgressView()
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .clipShape(Circle())
                @unknown default:
                    fatalError("unknown phase")
                }
            }
        }
    }
}
