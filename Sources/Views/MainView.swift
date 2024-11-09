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
        ) { users in
            ChannelTreeView(
                store: .init(initialState: ChannelTree.State(users: users)) {
                    ChannelTree()
                }
            )
        }
    }
}

#Preview {
    MainView()
}
