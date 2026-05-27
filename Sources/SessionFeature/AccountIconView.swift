import SwiftUI
import TraqAPI

package struct AccountIconView: View {
    let iconFileId: String?
    var size: CGFloat = 32

    package var body: some View {
        Group {
            if let iconFileId {
                URLImage(fileId: iconFileId)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
