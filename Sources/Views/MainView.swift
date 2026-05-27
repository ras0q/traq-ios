import ChannelFeature
import ChannelRepository
import ChannelTreeFeature
import MessageRepository
import Model
import SessionFeature
import SessionRepository
import SwiftUI

public struct MainView: View {
    @State private var catalog = TraqCatalog()
    @State private var selectedChannel: ChannelPresentation?
    @State private var preferredCompactColumn = NavigationSplitViewColumn.detail

    public init() {}

    public var body: some View {
        SessionView {
            NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
                ChannelTreeView(
                    selectedChannel: $selectedChannel,
                    onChannelSelected: { preferredCompactColumn = .detail }
                )
                .navigationTitle("Channels")
            } detail: {
                if let selectedChannel {
                    ChannelView(
                        channel: selectedChannel.channel,
                        channelPath: selectedChannel.channelPath
                    )
                } else {
                    ContentUnavailableView(
                        "チャンネル未選択",
                        systemImage: "number",
                        description: Text("サイドバーからチャンネルを選択してください。")
                    )
                }
            }
        }
        .environment(catalog)
        .environment(\.sessionRepository, LiveSessionRepository())
        .environment(\.channelRepository, LiveChannelRepository())
        .environment(\.messageRepository, LiveMessageRepository())
    }
}

#Preview {
    MainView()
        .environment(\.channelRepository, PreviewChannelRepository())
}
