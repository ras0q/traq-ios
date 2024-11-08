import ComposableArchitecture
import SwiftUI
import TraqAPI

package struct ChannelTree: Reducer {
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

    package struct State: Equatable {
        var rootChannels: [ChannelRecursive] = []
        var isLoading: Bool = false

        package init() {}
    }

    package enum Action {
        case view(ViewAction)
        case `internal`(InternalAction)

        package enum ViewAction {
            case onAppear
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
                case .onAppear:
                    state.isLoading = true
                    return .run { send in
                        let response = try await traqAPIClient.getChannels(query: .init(include_hyphen_dm: false))
                        await send(.internal(.getChannelsResponse(response)))
                    }
                }
            case let .internal(internalAction):
                switch internalAction {
                case let .getChannelsResponse(response):
                    state.isLoading = false
                    switch response {
                    case let .ok(ok):
                        return .run { send in
                            let publicChannels = try ok.body.json._public
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
            }
        }
    }
}

package struct ChannelTreeView: View {
    let store: StoreOf<ChannelTree>

    package init(store: StoreOf<ChannelTree>) {
        self.store = store
    }

    package var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                List(viewStore.rootChannels, id: \.id, children: \.children) {
                    ChannelTreeNodeView(
                        store: .init(
                            initialState: ChannelTreeNode.State(channel: $0.base)
                        ) {
                            ChannelTreeNode()
                        }
                    )
                }
            }
            .onAppear {
                viewStore.send(.view(.onAppear))
            }
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
