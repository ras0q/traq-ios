import Actuate
import ChannelFeature
import ChannelRepository
import Model
import SwiftUI

package struct ChannelTreeView: View {
    @State private var presentedChannel: ChannelPresentation?

    private var loadChannels = EnvironmentAsyncAction(\.channelRepository, policy: .refresh) {
        (repository: any ChannelRepository, _: EmptyInput) in
        try await repository.fetchChannelTree()
    }

    package init() {}

    package var body: some View {
        Group {
            switch loadChannels.phase {
            case .idle:
                ProgressView()
            case .loading(let previous):
                if let previous {
                    channelList(previous)
                } else {
                    ProgressView()
                }
            case .success(let channels):
                channelList(channels)
            case .failure(let error, let previous):
                VStack(spacing: 12) {
                    if let previous {
                        channelList(previous)
                    }
                    Text(error.localizedDescription)
                        .foregroundStyle(.red)
                        .font(.callout)
                    Button("Retry") {
                        Task {
                            await loadChannels.run(input: EmptyInput(), force: true)
                        }
                    }
                }
            }
        }
        .task {
            await loadChannels.run(input: EmptyInput())
        }
        .fullScreenCover(item: $presentedChannel) { presentation in
            ZStack {
                Button(action: {
                    presentedChannel = nil
                }) {
                    Text("")
                        .frame(
                            width: UIScreen.main.bounds.width,
                            height: UIScreen.main.bounds.height
                        )
                }

                ChannelView(
                    channel: presentation.channel,
                    channelPath: presentation.channelPath
                )
                .frame(
                    width: UIScreen.main.bounds.width * 0.9,
                    height: UIScreen.main.bounds.height * 0.8
                )
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .compositingGroup()
                .shadow(radius: 10)
            }
            .clearBackground()
        }
    }

    @ViewBuilder
    private func channelList(_ channels: [ChannelRecursive]) -> some View {
        List(channels, id: \.id, children: \.children) { channel in
            ChannelTreeNodeView(
                name: channel.base.name,
                hasChildren: channel.base.children.count > 0,
                onNodeTapped: {
                    presentedChannel = ChannelPresentation(
                        channel: channel.base,
                        channelPath: channel.path
                    )
                }
            )
        }
        .listStyle(.inset)
    }
}

#Preview {
    ChannelTreeView()
        .environment(\.channelRepository, PreviewChannelRepository())
}
