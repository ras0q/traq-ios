import Actuate
import MessageRepository
import Model
import SwiftUI
import TraqAPI

package struct ChannelView: View {
    @Environment(TraqCatalog.self) private var catalog

    private let channel: Components.Schemas.Channel
    private let channelPath: String

    private var loadChannel = EnvironmentAsyncAction(\.messageRepository, policy: .refresh) {
        repository, input in
        try await repository.loadChannel(input)
    }

    private var clipMessageAction = EnvironmentAsyncAction(\.messageRepository) {
        repository, input in
        try await repository.clipMessage(input)
    }

    package init(channel: Components.Schemas.Channel, channelPath: String) {
        self.channel = channel
        self.channelPath = channelPath
    }

    private var loadChannelInput: LoadChannelInput {
        LoadChannelInput(
            channelId: channel.id,
            loadClipFolder: catalog.clipFolderId == nil
        )
    }

    private var channelTitle: String {
        channelPath.replacing("/", maxReplacements: 1, with: { _ in "#" })
    }

    package var body: some View {
        VStack(alignment: .leading) {
            switch loadChannel.phase {
            case .idle, .loading(nil):
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loading(let previous?):
                ChannelMessageListView(messages: previous.messages, onClipMessage: clipMessage)
            case .success(let output):
                ChannelMessageListView(messages: output.messages, onClipMessage: clipMessage)
            case .failure(let error, let previous):
                VStack(spacing: 12) {
                    if let previous {
                        ChannelMessageListView(
                            messages: previous.messages, onClipMessage: clipMessage
                        )
                    } else {
                        Spacer()
                    }
                    Text(error.localizedDescription)
                        .foregroundStyle(.red)
                        .font(.callout)
                    Button("Retry") {
                        Task {
                            await reloadChannel(force: true)
                        }
                    }
                    Spacer()
                }
            }
        }
        .navigationTitle(channelTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: loadChannelInput) {
            await reloadChannel()
        }
    }

    private func reloadChannel(force: Bool = false) async {
        await loadChannel.run(input: loadChannelInput, force: force)
        guard case .success(let output) = loadChannel.phase else {
            return
        }
        if let clipFolderId = output.clipFolderId {
            catalog.clipFolderId = clipFolderId
        }
    }

    private func clipMessage(_ messageId: String) async {
        guard let clipFolderId = catalog.clipFolderId else {
            return
        }
        await clipMessageAction.run(
            input: ClipMessageInput(folderId: clipFolderId, messageId: messageId)
        )
    }
}
