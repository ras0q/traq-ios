import ChannelFeature
import ComposableArchitecture
import SwiftUI
import TraqAPI

@Reducer
package struct ChannelTree {
    package struct ChannelRecursive: Identifiable, Equatable {
        package var id: String { base.id }
        let base: Components.Schemas.Channel
        let children: [ChannelRecursive]?

        init(base: Components.Schemas.Channel, children: [ChannelRecursive]?) {
            self.base = base
            self.children = children
        }

        init?(channels: [Components.Schemas.Channel], rootId: String? = nil) {
            func getDescendants(parentId: String?) -> [ChannelRecursive]? {
                let children = channels.filter { $0.parentId == parentId }
                return children.map {
                    ChannelRecursive(base: $0, children: getDescendants(parentId: $0.id))
                }
            }

            base = channels.first { $0.id == rootId } ?? .mock(0)
            children = getDescendants(parentId: rootId)
        }
    }

    @ObservableState
    package struct State: Equatable {
        var rootChannels: [ChannelRecursive] = []
        var isLoading: Bool = false
        @Presents var destination: Channel.State?

        package init() {}
    }

    package enum Action {
        case view(ViewAction)
        case `internal`(InternalAction)
        case destination(PresentationAction<Channel.Action>)

        package enum ViewAction {
            case appeared
            case nodeTapped(channel: Components.Schemas.Channel)
            case nodeDismissed
        }

        package enum InternalAction {
            case getChannelsResponse(Operations.getChannels.Output)
            case channelTreeConstructed([ChannelRecursive])
        }
    }

    package init() {}

    package var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .appeared:
                    state.isLoading = true
                    return .run { send in
                        let response = try await traqAPIClient.getChannels(query: .init(include_hyphen_dm: false))
                        await send(.internal(.getChannelsResponse(response)))
                    }
                case let .nodeTapped(channel: channel):
                    state.destination = Channel.State(channel: channel)
                case .nodeDismissed:
                    state.destination = nil
                }
                return .none
            case let .internal(internalAction):
                switch internalAction {
                case let .getChannelsResponse(response):
                    state.isLoading = false
                    switch response {
                    case let .ok(ok):
                        return .run { send in
                            let publicChannels = try ok.body.json._public.filter { !$0.archived }
                            let rootChannels = ChannelRecursive(channels: publicChannels)?.children ?? []
                            await send(.internal(.channelTreeConstructed(rootChannels)))
                        }
                    default:
                        print(response)
                    }
                case let .channelTreeConstructed(rootChannels):
                    state.rootChannels = rootChannels
                }
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Channel()
        }
    }
}

package struct ChannelTreeView: View {
    @Bindable var store: StoreOf<ChannelTree>
    let viewStore: ViewStoreOf<ChannelTree>

    package init(store: StoreOf<ChannelTree>) {
        self.store = store
        self.viewStore = ViewStoreOf<ChannelTree>(store, observe: { $0 })
    }

    package var body: some View {
        List(viewStore.rootChannels, id: \.id, children: \.children) { channel in
            ChannelTreeNodeView(
                name: channel.base.name,
                hasChildren: channel.base.children.count > 0,
                onNodeTapped: {
                    viewStore.send(.view(.nodeTapped(channel: channel.base)))
                }
            )
        }
        .onAppear {
            viewStore.send(.view(.appeared))
        }
        .fullScreenCover(item: $store.scope(state: \.destination, action: \.destination)) { store in
            ZStack {
                Button(action: {
                    viewStore.send(.view(.nodeDismissed))
                }) {
                    Text("")
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: UIScreen.main.bounds.height
                    )
                }

                ChannelView(store: store)
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
}

#Preview {
    ChannelTreeView(
        store: .init(initialState: ChannelTree.State()) {
            ChannelTree()
                ._printChanges()
        }
    )
}
