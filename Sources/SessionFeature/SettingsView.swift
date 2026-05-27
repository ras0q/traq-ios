import Model
import SwiftUI
import TraqAPI

package struct SettingsView: View {
    @Environment(TraqCatalog.self) private var catalog

    package init() {}

    package var body: some View {
        List {
            if let currentUser = catalog.currentUser {
                Section {
                    HStack(spacing: 16) {
                        AccountIconView(iconFileId: currentUser.iconFileId, size: 56)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentUser.displayName)
                                .font(.headline)
                            Text("@\(currentUser.name)")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    if !currentUser.bio.isEmpty {
                        Text(currentUser.bio)
                            .font(.body)
                    }
                }
            }
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(
        TraqCatalog(
            currentUser: Components.Schemas.MyUserDetail(
                id: "00000000-0000-4000-8000-000000000001",
                bio: "Hello, traQ!",
                groups: [],
                tags: [],
                updatedAt: .now,
                twitterId: "preview",
                name: "preview",
                displayName: "Preview User",
                iconFileId: "00000000-0000-4000-8000-000000000002",
                bot: false,
                state: ._0,
                permissions: []
            )
        )
    )
}
