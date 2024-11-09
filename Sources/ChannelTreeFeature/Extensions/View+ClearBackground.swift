// https://dev.classmethod.jp/articles/swiftui-mr-transparent/

import SwiftUI

struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        Task {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension View {
    func clearBackground() -> some View {
        background(ClearBackgroundView())
    }
}
