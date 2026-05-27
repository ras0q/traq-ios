import Model
import SwiftUI

package struct AccountToolbarContent: ToolbarContent {
    @Environment(TraqCatalog.self) private var catalog

    package init() {}

    package var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink {
                SettingsView()
            } label: {
                AccountIconView(iconFileId: catalog.currentUser?.iconFileId)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("設定")
        }
    }
}
