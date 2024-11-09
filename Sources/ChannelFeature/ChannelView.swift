import ComposableArchitecture
import MarkdownFeature
import SwiftUI
import TraqAPI

@Reducer
package struct Channel {
    @ObservableState
    package struct State: Equatable {
        let channel: Components.Schemas.Channel
        let users: [Components.Schemas.User]
        var messages: [Components.Schemas.Message] = []

        package init(channel: Components.Schemas.Channel, users: [Components.Schemas.User]) {
            self.channel = channel
            self.users = users
        }
    }

    package enum Action {
        case view(ViewAction)
        case `internal`(InternalAction)

        package enum ViewAction {
            case appeared
        }

        package enum InternalAction {
            case getMessagesResponse(Operations.getMessages.Output)
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
                    return .run { [channel = state.channel] send in
                        let response = try await traqAPIClient.getMessages(
                            path: .init(channelId: channel.id),
                            query: .init(order: .desc)
                        )
                        await send(.internal(.getMessagesResponse(response)))
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
                    return .none
                }
            }
        }
    }
}

package struct ChannelView: View {
    let store: StoreOf<Channel>

    package init(store: StoreOf<Channel>) {
        self.store = store
    }

    package var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                Text("#\(viewStore.channel.name)")
                    .font(.title)
                    .bold()
                List(viewStore.messages, id: \.id) { message in
                    ChannelMessageView(
                        message: message,
                        user: viewStore.users.first(where: { $0.id == message.userId })!
                    )
                }
                .listStyle(.inset)
                Spacer()
            }
            .padding()
            .onAppear {
                viewStore.send(.view(.appeared))
            }
        }
    }
}
