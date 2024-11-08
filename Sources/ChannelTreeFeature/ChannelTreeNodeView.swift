import ComposableArchitecture
import SwiftUI
import TraqAPI

package struct ChannelTreeNode: Reducer {
    package struct State: Equatable, Identifiable {
        package var id: String { channel.id }
        let channel: Components.Schemas.Channel
    }

    package enum Action: Equatable {
        case onTapped
    }

    package var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onTapped:
                return .none
            }
        }
    }
}

struct ChannelTreeNodeView: View {
    let store: StoreOf<ChannelTreeNode>

    init(store: StoreOf<ChannelTreeNode>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                hashImageView(haveChildren: viewStore.channel.children.count > 0)

                // Buttonだと行全体に判定がついてしまうため.onTapGestureを使う
                HStack {
                    Text(viewStore.channel.name)
                    Spacer()
                }
                .contentShape(Rectangle()) // Spacerにも判定をつける
                .onTapGesture {
                    viewStore.send(.onTapped)
                }
            }
        }
    }

    private func hashImageView(haveChildren: Bool) -> some View {
        HStack {
            let imageView = Image(systemName: "number")
                .fixedSize()
                .padding(4)

            if haveChildren {
                imageView
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black, lineWidth: 2)
                    )
            } else {
                imageView
            }
        }
    }
}

#Preview {
    ForEach(0 ..< 5) { index in
        ChannelTreeNodeView(store: .init(
            initialState: ChannelTreeNode.State(channel: .mock(index))
        ) {
            ChannelTreeNode()
        })
    }
}
