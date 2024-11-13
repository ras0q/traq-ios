import ComposableArchitecture
import MarkdownFeature
import SwiftUI
import TraqAPI

struct ChannelMessageView: View {
    let message: Components.Schemas.Message
    let user: Components.Schemas.User
    let stamps: [Components.Schemas.StampWithThumbnail]
    let messageStampsGroupby: [String : [Components.Schemas.MessageStamp]]

    init(message: Components.Schemas.Message, user: Components.Schemas.User, stamps: [Components.Schemas.StampWithThumbnail]) {
        self.message = message
        self.user = user
        self.stamps = stamps
        self.messageStampsGroupby = .init(grouping: message.stamps) { $0.stampId }
    }

    var body: some View {
        HStack(alignment: .top) {
            URLImage(fileId: user.iconFileId)
                .clipShape(Circle())
                .frame(width: 40, height: 40)
            VStack (alignment: .leading) {
                HStack {
                    Text(user.displayName).bold()
                    Text("@\(user.name)").font(.callout).foregroundStyle(Color.gray)
                }
                Markdown("\(message.content)", stamps: stamps)

                LazyVGrid(
                    columns: Array(repeating: GridItem(.adaptive(minimum: 50)), count: 1),
                    spacing: 10
                ) {
                    ForEach(messageStampsGroupby.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            URLImage(stampId: value[0].stampId)
                                .frame(width: 24, height: 24)
                            Text("\(value.count)").font(.callout)
                        }
                    }
                }
            }
        }
    }
}
