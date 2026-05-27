import Foundation
import Model
import TraqAPI

package struct LiveMessageRepository: MessageRepository {
    private let client: Client

    package init(client: Client? = nil) {
        self.client = client ?? traqAPIClient
    }

    package func loadChannel(_ input: LoadChannelInput) async throws -> LoadChannelOutput {
        let messagesResponse = try await client.getMessages(
            path: .init(channelId: input.channelId),
            query: .init(order: .desc)
        )

        let messages: [Components.Schemas.Message]
        switch messagesResponse {
        case .ok(let okResponse):
            messages = try okResponse.body.json.sorted { $0.createdAt < $1.createdAt }
        default:
            throw RepositoryError.unexpectedResponse
        }

        guard input.loadClipFolder else {
            return LoadChannelOutput(messages: messages, clipFolderId: nil)
        }

        let clipFoldersResponse = try await client.getClipFolders()
        switch clipFoldersResponse {
        case .ok(let okResponse):
            let clipFolderId = try okResponse.body.json.first?.id
            return LoadChannelOutput(messages: messages, clipFolderId: clipFolderId)
        default:
            throw RepositoryError.unexpectedResponse
        }
    }

    package func clipMessage(_ input: ClipMessageInput) async throws {
        let response = try await client.clipMessage(
            path: .init(folderId: input.folderId),
            body: .json(.init(messageId: input.messageId))
        )
        switch response {
        case .ok:
            return
        default:
            throw RepositoryError.unexpectedResponse
        }
    }
}

package struct PreviewMessageRepository: MessageRepository {
    package init() {}

    package func loadChannel(_ input: LoadChannelInput) async throws -> LoadChannelOutput {
        try await Task.sleep(for: .milliseconds(300))
        return LoadChannelOutput(
            messages: [],
            clipFolderId: input.loadClipFolder ? "clip-folder-1" : nil
        )
    }

    package func clipMessage(_ input: ClipMessageInput) async throws {
        try await Task.sleep(for: .milliseconds(200))
    }
}
