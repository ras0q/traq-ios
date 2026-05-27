import ChannelFeature
import ChannelRepository
import ChannelTreeFeature
import MessageRepository
import Model
import SessionFeature
import SessionRepository
import SwiftUI

public struct MainView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var catalog = TraqCatalog()
    @State private var selectedChannel: ChannelPresentation?

    public init() {}

    public var body: some View {
        SessionView {
            Group {
                if horizontalSizeClass == .compact {
                    compactNavigation
                } else {
                    splitNavigation
                }
            }
        }
        .environment(catalog)
        .environment(\.sessionRepository, LiveSessionRepository())
        .environment(\.channelRepository, LiveChannelRepository())
        .environment(\.messageRepository, LiveMessageRepository())
    }

    private var compactNavigation: some View {
        NavigationStack {
            ChannelTreeView(selectedChannel: $selectedChannel)
                .navigationTitle("Channels")
                .navigationDestination(item: $selectedChannel) { presentation in
                    ChannelView(
                        channel: presentation.channel,
                        channelPath: presentation.channelPath
                    )
                }
                .toolbar { AccountToolbarContent() }
        }
    }

    private var splitNavigation: some View {
        NavigationSplitView {
            NavigationStack {
                ChannelTreeView(selectedChannel: $selectedChannel)
                    .navigationTitle("Channels")
            }
        } detail: {
            NavigationStack {
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
            .toolbar { AccountToolbarContent() }
        }
    }
}

#Preview {
    MainView()
        .environment(\.channelRepository, PreviewChannelRepository())
}
