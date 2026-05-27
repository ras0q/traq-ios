import Foundation
import Model
import SwiftUI

package protocol SessionRepository: Sendable {
    func checkSession() async throws -> Bool
    func login(_ input: LoginInput) async throws
    func fetchCatalog() async throws -> CatalogData
}

private struct SessionRepositoryKey: EnvironmentKey {
    static let defaultValue: any SessionRepository = PreviewSessionRepository()
}

extension EnvironmentValues {
    package var sessionRepository: any SessionRepository {
        get { self[SessionRepositoryKey.self] }
        set { self[SessionRepositoryKey.self] = newValue }
    }
}
