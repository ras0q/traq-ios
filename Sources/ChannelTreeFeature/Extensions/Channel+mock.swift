import Foundation
import TraqAPI

extension Components.Schemas.Channel {
    private static let channelID1 = UUID(uuidString: "11111111-1111-4111-1111-111111111111")

    @Sendable static func mock(_ index: Int) -> Components.Schemas.Channel {
        Components.Schemas.Channel(
            id: UUID(index).uuidString,
            parentId: index >= 3 ? UUID(index / 3).uuidString : nil,
            archived: Bool.random(),
            force: Bool.random(),
            topic: "topic",
            name: "name\(index)",
            children: (0 ..< 3).map { UUID(3 * index + $0).uuidString }
        )
    }
}

extension Components.Schemas.Channel {
    @Sendable static func mock(_: Int) -> Components.Schemas.DMChannel {
        Components.Schemas.DMChannel(id: UUID().uuidString, userId: UUID().uuidString)
    }
}
