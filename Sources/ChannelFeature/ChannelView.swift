import ComposableArchitecture
import MarkdownFeature
import SwiftUI
import TraqAPI

@Reducer
package struct Channel {
    @ObservableState
    package struct State: Equatable {
        let channel: Components.Schemas.Channel
        let channelPath: String
        var messages: [Components.Schemas.Message] = []
        @Shared(.inMemory("users"))
        package var users: [Components.Schemas.User] = []
        @Shared(.inMemory("stamps"))
        package var stamps: [Components.Schemas.StampWithThumbnail] = []
        @Shared(.inMemory("clipFolderId"))
        package var clipFolderId: String? = nil

        package init(channel: Components.Schemas.Channel, channelPath: String) {
            self.channel = channel
            self.channelPath = channelPath
        }
    }

    package enum Action: ViewAction {
        case view(ViewAction)
        case `internal`(InternalAction)

        package enum ViewAction {
            case appeared
            case messageClipped(messageId: String)
        }

        package enum InternalAction {
            case getMessagesResponse(Operations.getMessages.Output)
            case getClipFoldersResponse(Operations.getClipFolders.Output)
            case clipMessageResponse(Operations.clipMessage.Output)
        }
    }

    package init() {}

    package var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .appeared:
                    return .run { [channel = state.channel, clipFolderId = state.clipFolderId] send in
                        let response = try await traqAPIClient.getMessages(
                            path: .init(channelId: channel.id),
                            query: .init(order: .desc)
                        )
                        await send(.internal(.getMessagesResponse(response)))

                        if clipFolderId == nil {
                            let response = try await traqAPIClient.getClipFolders()
                            await send(.internal(.getClipFoldersResponse(response)))
                        }
                    }
                case let .messageClipped(messageId: messageId):
                    guard let clipFolderId = state.clipFolderId else {
                        print("clipFolderId not specified")
                        return .none
                    }
                    return .run { send in
                        let response = try await traqAPIClient.clipMessage(
                            path: .init(folderId: clipFolderId),
                            body: .json(.init(messageId: messageId))
                        )
                        await send(.internal(.clipMessageResponse(response)))
                    }
                }
            case let .internal(internalAction):
                switch internalAction {
                case let .getMessagesResponse(response):
                    switch response {
                    case let .ok(okResponse):
                        do {
                            state.messages = try okResponse.body.json
                                .sorted { $0.createdAt < $1.createdAt }
                        } catch {
                            print(error)
                        }
                    default:
                        print(response)
                    }
                case let .getClipFoldersResponse(response):
                    switch response {
                    case let .ok(okResponse):
                        do {
                            state.clipFolderId = try okResponse.body.json.first?.id
                        } catch {
                            print(error)
                        }
                    default:
                        print(response)
                    }
                case let .clipMessageResponse(response):
                    switch response {
                    case .ok:
                        return .none
                    default:
                        print(response)
                    }
                }
                return .none
            }
        }
    }
}

@ViewAction(for: Channel.self)
package struct ChannelView: View {
    package let store: StoreOf<Channel>

    package init(store: StoreOf<Channel>) {
        self.store = store
    }

    package var body: some View {
        VStack(alignment: .leading) {
            Text(store.channelPath.replacing("/", maxReplacements: 1, with: { _ in "#" }))
                .font(.title)
                .bold()
            List(store.messages, id: \.id) { message in
                ChannelMessageView(
                    message: message,
                    user: store.users.first(where: { $0.id == message.userId })!,
                    stamps: store.stamps
                )
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        send(.messageClipped(messageId: message.id))
                    } label: {
                        Label("クリップ", systemImage: "bookmark.fill")
                    }
                    .tint(.green)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        UIPasteboard.general.string = "https://\(traqServerURL.host()!)/messages/\(message.id)"
                    } label: {
                        Label("リンクをコピー", systemImage: "link")
                    }
                    .tint(.blue)
                }
            }
            .listStyle(.inset)
            Spacer()
        }
        .padding()
        .onAppear {
            send(.appeared)
        }
    }
}
