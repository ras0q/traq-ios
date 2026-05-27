import Foundation
import Model
import TraqAPI

package struct LiveChannelRepository: ChannelRepository {
    private let client: Client

    package init(client: Client? = nil) {
        self.client = client ?? traqAPIClient
    }

    package func fetchChannelTree() async throws -> [ChannelRecursive] {
        let response = try await client.getChannels(query: .init(include_hyphen_dm: false))
        switch response {
        case .ok(let ok):
            let publicChannels = try ok.body.json._public
                .filter { !$0.archived }
                .sorted { $0.name.lowercased() < $1.name.lowercased() }
            return ChannelRecursive(channels: publicChannels)?.children ?? []
        default:
            throw RepositoryError.unexpectedResponse
        }
    }
}

package struct PreviewChannelRepository: ChannelRepository {
    package init() {}

    package func fetchChannelTree() async throws -> [ChannelRecursive] {
        try await Task.sleep(for: .milliseconds(300))
        let channels = (0..<6).map { Components.Schemas.Channel.mock($0) }
        return ChannelRecursive(channels: channels)?.children ?? []
    }
}
