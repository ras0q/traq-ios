import Foundation
import TraqAPI

package struct ChannelRecursive: Identifiable, Equatable, Sendable {
    package var id: String { base.id }
    package let base: Components.Schemas.Channel
    package let path: String
    package let children: [ChannelRecursive]?

    package init(base: Components.Schemas.Channel, path: String, children: [ChannelRecursive]?) {
        self.base = base
        self.path = path
        self.children = children
    }

    package init?(channels: [Components.Schemas.Channel], rootId: String? = nil) {
        func getDescendants(parentId: String?, parentPath: String) -> [ChannelRecursive]? {
            let children = channels.filter { $0.parentId == parentId }
            return children.map {
                let path = "\(parentPath)/\($0.name)"
                return ChannelRecursive(
                    base: $0,
                    path: path,
                    children: getDescendants(parentId: $0.id, parentPath: path)
                )
            }
        }

        base = channels.first { $0.id == rootId } ?? .mock(0)
        path = ""
        children = getDescendants(parentId: rootId, parentPath: "")
    }
}

package struct ChannelPresentation: Identifiable, Sendable {
    package let channel: Components.Schemas.Channel
    package let channelPath: String

    package var id: String { channel.id }

    package init(channel: Components.Schemas.Channel, channelPath: String) {
        self.channel = channel
        self.channelPath = channelPath
    }
}
