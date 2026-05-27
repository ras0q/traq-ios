import ChannelRepository
import ChannelTreeFeature
import MessageRepository
import Model
import SessionFeature
import SessionRepository
import SwiftUI

public struct MainView: View {
    @State private var catalog = TraqCatalog()

    public init() {}

    public var body: some View {
        SessionView {
            NavigationStack {
                ChannelTreeView()
                    .navigationTitle("Channels")
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
}
