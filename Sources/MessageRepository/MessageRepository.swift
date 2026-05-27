import Foundation
import Model
import SwiftUI

package protocol MessageRepository: Sendable {
    func loadChannel(_ input: LoadChannelInput) async throws -> LoadChannelOutput
    func clipMessage(_ input: ClipMessageInput) async throws
}

private struct MessageRepositoryKey: EnvironmentKey {
    static let defaultValue: any MessageRepository = PreviewMessageRepository()
}

extension EnvironmentValues {
    package var messageRepository: any MessageRepository {
        get { self[MessageRepositoryKey.self] }
        set { self[MessageRepositoryKey.self] = newValue }
    }
}
