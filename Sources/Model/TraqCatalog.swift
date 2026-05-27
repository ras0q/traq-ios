import Foundation
import Observation
import TraqAPI

extension Components.Schemas.User: Identifiable {}

@Observable
public final class TraqCatalog {
    package var users: [Components.Schemas.User] = []
    package var stamps: [Components.Schemas.StampWithThumbnail] = []
    package var currentUser: Components.Schemas.MyUserDetail?
    package var clipFolderId: String?

    package init(
        users: [Components.Schemas.User] = [],
        stamps: [Components.Schemas.StampWithThumbnail] = [],
        currentUser: Components.Schemas.MyUserDetail? = nil,
        clipFolderId: String? = nil
    ) {
        self.users = users
        self.stamps = stamps
        self.currentUser = currentUser
        self.clipFolderId = clipFolderId
    }
}
