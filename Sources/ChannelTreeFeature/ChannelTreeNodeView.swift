import SwiftUI
import TraqAPI

struct ChannelTreeNodeView: View {
    let name: String
    let hasChildren: Bool
    let onNodeTapped: () -> Void

    init(name: String, hasChildren: Bool, onNodeTapped: @escaping () -> Void) {
        self.name = name
        self.hasChildren = hasChildren
        self.onNodeTapped = onNodeTapped
    }

    var body: some View {
        HStack {
            hashImageView(hasChildren: hasChildren)

            // Buttonだと行全体に判定がついてしまうため.onTapGestureを使う
            HStack {
                Text(name)
                Spacer()
            }
            .contentShape(Rectangle()) // Spacerにも判定をつける
            .onTapGesture {
                onNodeTapped()
            }
        }
    }

    private func hashImageView(hasChildren: Bool) -> some View {
        HStack {
            let imageView = Image(systemName: "number")
                .fixedSize()
                .padding(4)

            if hasChildren {
                imageView
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black, lineWidth: 2)
                    )
            } else {
                imageView
            }
        }
    }
}

#Preview {
    ForEach(0 ..< 5) { index in
        ChannelTreeNodeView(
            name: "channel\(index)", hasChildren: Bool.random()) {
                print("channel\(index) tapped")
            }
    }
}
