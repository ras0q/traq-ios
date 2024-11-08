import ComposableArchitecture
import SwiftUI
import TraqAPI

package struct Session: Reducer {
    package struct State: Equatable {
        var isLogined: Bool

        package init(isLogined: Bool = false) {
            self.isLogined = isLogined
        }
    }

    package enum Action {
        case view(ViewAction)
        case `internal`(InternalAction)

        package enum ViewAction {
            case onAppear
            case loginButtonTapped(name: String, password: String)
        }

        package enum InternalAction {
            case getMeResponse(Operations.getMe.Output)
            case loginResponse(Operations.login.Output)
        }
    }

    package init() {}

    package var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onAppear:
                    return .run { send in
                        let response = try await traqAPIClient.getMe()
                        await send(.internal(.getMeResponse(response)))
                    }
                case let .loginButtonTapped(name: name, password: password):
                    return .run { send in
                        let response = try await traqAPIClient.login(
                            body: .some(.json(.init(name: name, password: password)))
                        )
                        await send(.internal(.loginResponse(response)))
                    }
                }
            case let .internal(internalAction):
                switch internalAction {
                case let .getMeResponse(response):
                    switch response {
                    case .ok:
                        state.isLogined = true
                    default:
                        state.isLogined = false
                        print(response)
                    }
                case let .loginResponse(response):
                    switch response {
                    case .noContent:
                        state.isLogined = true
                    default:
                        state.isLogined = false
                        print(response)
                    }
                }
                return .none
            }
        }
    }
}

package struct SessionView<Content: View>: View {
    @State private var id: String = ""
    @State private var password: String = ""
    private let store: StoreOf<Session>
    private let contentView: () -> Content

    package init(store: StoreOf<Session>, contentView: @escaping () -> Content) {
        self.store = store
        self.contentView = contentView
    }

    package var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .center, spacing: 16) {
                if viewStore.isLogined {
                    contentView()
                } else {
                    TextField("ID", text: $id)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .overlay { borderStyle }
                    SecureField("Password", text: $password)
                        .keyboardType(.asciiCapable)
                        .padding()
                        .overlay { borderStyle }
                    Button("ログイン") {
                        viewStore.send(.view(.loginButtonTapped(name: id, password: password)))
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .onAppear {
                viewStore.send(.view(.onAppear))
            }
        }
    }

    private var borderStyle: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(.primary, lineWidth: 1)
    }
}

#Preview {
    SessionView(
        store: .init(initialState: Session.State()) {
            Session()
                ._printChanges()
        }
    ) {
        Text("Login succeeded!")
    }
}
