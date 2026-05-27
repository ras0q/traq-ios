import Model
import SwiftUI
import TraqAPI

struct ChannelMessageListView: View {
    @Environment(TraqCatalog.self) private var catalog

    let messages: [Components.Schemas.Message]
    let onClipMessage: (String) async -> Void

    var body: some View {
        if messages.isEmpty {
            ContentUnavailableView(
                "メッセージがありません",
                systemImage: "bubble.left.and.bubble.right",
                description: Text("このチャンネルにはまだメッセージがありません。")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(messages, id: \.id) { message in
                if let user = catalog.users.first(where: { $0.id == message.userId }) {
                    ChannelMessageView(
                        message: message,
                        user: user,
                        stamps: catalog.stamps
                    )
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            Task {
                                await onClipMessage(message.id)
                            }
                        } label: {
                            Label("クリップ", systemImage: "bookmark.fill")
                        }
                        .tint(.green)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            UIPasteboard.general.string =
                                "https://\(traqServerURL.host()!)/messages/\(message.id)"
                        } label: {
                            Label("リンクをコピー", systemImage: "link")
                        }
                        .tint(.blue)
                    }
                }
            }
            .listStyle(.inset)
        }
    }
}
