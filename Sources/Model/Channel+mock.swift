import Foundation
import TraqAPI

extension UUID {
    fileprivate init(index: Int) {
        self.init(uuidString: String(format: "00000000-0000-4000-8000-%012x", index))!
    }
}

extension Components.Schemas.Channel {
    package static func mock(_ index: Int) -> Components.Schemas.Channel {
        Components.Schemas.Channel(
            id: UUID(index: index).uuidString,
            parentId: index >= 3 ? UUID(index: index / 3).uuidString : nil,
            archived: false,
            force: false,
            topic: "topic",
            name: "name\(index)",
            children: (0..<3).map { UUID(index: 3 * index + $0).uuidString }
        )
    }
}

extension Components.Schemas.Channel {
    package static func mockDM(_: Int) -> Components.Schemas.DMChannel {
        Components.Schemas.DMChannel(id: UUID().uuidString, userId: UUID().uuidString)
    }
}
