import Foundation
import Model
import TraqAPI

package struct LiveSessionRepository: SessionRepository {
    private let client: Client

    package init(client: Client? = nil) {
        self.client = client ?? traqAPIClient
    }

    package func checkSession() async throws -> Bool {
        let response = try await client.getMe()
        switch response {
        case .ok:
            return true
        default:
            return false
        }
    }

    package func login(_ input: LoginInput) async throws {
        let response = try await client.login(
            body: .some(.json(.init(name: input.name, password: input.password)))
        )
        switch response {
        case .noContent:
            return
        default:
            throw RepositoryError.unexpectedResponse
        }
    }

    package func fetchMe() async throws -> Components.Schemas.MyUserDetail {
        let response = try await client.getMe()
        switch response {
        case .ok(let ok):
            return try ok.body.json
        default:
            throw RepositoryError.unexpectedResponse
        }
    }

    package func fetchCatalog() async throws -> CatalogData {
        async let usersResponse = client.getUsers(
            .init(query: .init(include_hyphen_suspended: true)))
        async let stampsResponse = client.getStamps()

        let users = try await usersResponse
        let stamps = try await stampsResponse

        switch (users, stamps) {
        case (.ok(let usersOK), .ok(let stampsOK)):
            return CatalogData(
                users: try usersOK.body.json,
                stamps: try stampsOK.body.json
            )
        default:
            throw RepositoryError.unexpectedResponse
        }
    }
}
