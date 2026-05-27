import Foundation
import Model
import SwiftUI

package protocol ChannelRepository: Sendable {
    func fetchChannelTree() async throws -> [ChannelRecursive]
}

private struct ChannelRepositoryKey: EnvironmentKey {
    static let defaultValue: any ChannelRepository = PreviewChannelRepository()
}

extension EnvironmentValues {
    package var channelRepository: any ChannelRepository {
        get { self[ChannelRepositoryKey.self] }
        set { self[ChannelRepositoryKey.self] = newValue }
    }
}
