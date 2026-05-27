import Foundation
import TraqAPI

package struct CatalogData: Sendable, Equatable {
    package let users: [Components.Schemas.User]
    package let stamps: [Components.Schemas.StampWithThumbnail]

    package init(
        users: [Components.Schemas.User],
        stamps: [Components.Schemas.StampWithThumbnail]
    ) {
        self.users = users
        self.stamps = stamps
    }
}

package struct LoginInput: Sendable, Equatable {
    package let name: String
    package let password: String

    package init(name: String, password: String) {
        self.name = name
        self.password = password
    }
}
