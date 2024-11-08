import ComposableArchitecture
import SwiftUI
import TraqAPI

package struct ChannelTree: Reducer {
    struct ChannelRecursive: Identifiable, Equatable {
        var id: String { base.id }
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
        var channels: [ChannelRecursive] = []
        var isLoading: Bool = false
        var error: String?

        package init() {}
    }

    package enum Action: Equatable {
        case onAppear
        case fetchChannelsResponse(TaskResult<[Components.Schemas.Channel]>)
    }

    package init() {}

    package var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(.fetchChannelsResponse(TaskResult {
                        try await traqAPIClient.getChannels(query: .init(include_hyphen_dm: false)).ok.body.json._public
                    }))
                }
            case let .fetchChannelsResponse(result):
                state.isLoading = false
                switch result {
                case let .success(response):
                    state.channels = ChannelRecursive(channels: response)?.children ?? []
                case let .failure(error):
                    print(error.localizedDescription)
                    state.error = error.localizedDescription
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
            if let error = viewStore.error {
                Text(error)
            }

            Group {
                List(viewStore.channels, id: \.id, children: \.children) {
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
                viewStore.send(.onAppear)
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
