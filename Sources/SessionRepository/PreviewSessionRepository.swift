import Foundation
import Model

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
}
