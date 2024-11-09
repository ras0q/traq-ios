import ComposableArchitecture
import SwiftUI
import TraqAPI

package struct Channel: Reducer {
    package struct State: Equatable {
        let channel: Components.Schemas.Channel

        package init(channel: Components.Schemas.Channel) {
            self.channel = channel
        }
    }

    package struct Action {}

    package init() {}

    package var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
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
            Text("\(viewStore.channel)")
        }
    }
}
