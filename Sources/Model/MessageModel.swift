import Foundation
import TraqAPI

package struct LoadChannelInput: Sendable, Equatable {
    package let channelId: String
    package let loadClipFolder: Bool

    package init(channelId: String, loadClipFolder: Bool) {
        self.channelId = channelId
        self.loadClipFolder = loadClipFolder
    }
}

package struct LoadChannelOutput: Sendable, Equatable {
    package let messages: [Components.Schemas.Message]
    package let clipFolderId: String?

    package init(messages: [Components.Schemas.Message], clipFolderId: String?) {
        self.messages = messages
        self.clipFolderId = clipFolderId
    }
}

package struct ClipMessageInput: Sendable, Equatable {
    package let folderId: String
    package let messageId: String

    package init(folderId: String, messageId: String) {
        self.folderId = folderId
        self.messageId = messageId
    }
}
