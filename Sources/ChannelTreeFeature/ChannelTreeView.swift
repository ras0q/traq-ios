import Actuate
import ChannelRepository
import Model
import SwiftUI

package struct ChannelTreeView: View {
    @Binding private var selectedChannel: ChannelPresentation?
    private let onChannelSelected: () -> Void

    private var loadChannels = EnvironmentAsyncAction(\.channelRepository, policy: .refresh) {
        (repository: any ChannelRepository, _: EmptyInput) in
        try await repository.fetchChannelTree()
    }

    package init(
        selectedChannel: Binding<ChannelPresentation?>,
        onChannelSelected: @escaping () -> Void = {}
    ) {
        _selectedChannel = selectedChannel
        self.onChannelSelected = onChannelSelected
    }

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
    }

    @ViewBuilder
    private func channelList(_ channels: [ChannelRecursive]) -> some View {
        List(channels, id: \.id, children: \.children) { channel in
            ChannelTreeNodeView(
                name: channel.base.name,
                hasChildren: channel.base.children.count > 0,
                onNodeTapped: {
                    selectedChannel = ChannelPresentation(
                        channel: channel.base,
                        channelPath: channel.path
                    )
                    onChannelSelected()
                }
            )
        }
        .listStyle(.inset)
    }
}

#Preview {
    @Previewable @State var selectedChannel: ChannelPresentation?

    ChannelTreeView(selectedChannel: $selectedChannel)
        .environment(\.channelRepository, PreviewChannelRepository())
}
