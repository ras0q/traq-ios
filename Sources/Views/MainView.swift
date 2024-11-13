import ChannelTreeFeature
import SessionFeature
import SwiftUI

public struct MainView: View {
    public init() {}

    public var body: some View {
        SessionView(
            store: .init(initialState: Session.State()) {
                Session()
            }
        ) {
            NavigationStack {
                ChannelTreeView(
                    store: .init(initialState: ChannelTree.State()) {
                        ChannelTree()
                    }
                )
                .navigationTitle("Channels")
            }
        }
    }
}

#Preview {
    MainView()
}
