import Foundation
import Model
import TraqAPI

package struct PreviewSessionRepository: SessionRepository {
    private let isLoggedIn: Bool

    package init(isLoggedIn: Bool = false) {
        self.isLoggedIn = isLoggedIn
    }

    package func checkSession() async throws -> Bool {
        try await Task.sleep(for: .milliseconds(200))
        return isLoggedIn
    }

    package func login(_ input: LoginInput) async throws {
        try await Task.sleep(for: .milliseconds(300))
        guard !input.name.isEmpty, !input.password.isEmpty else {
            throw RepositoryError.unexpectedResponse
        }
    }

    package func fetchCatalog() async throws -> CatalogData {
        try await Task.sleep(for: .milliseconds(200))
        return CatalogData(users: [], stamps: [])
    }

    package func fetchMe() async throws -> Components.Schemas.MyUserDetail {
        try await Task.sleep(for: .milliseconds(200))
        return Components.Schemas.MyUserDetail(
            id: "00000000-0000-4000-8000-000000000001",
            bio: "",
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
    }
}
